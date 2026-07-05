# platform-engineering-lab

### 1. Create React App

#### 1.1 Open terminal

```bash
npx create-react-app ci-cd-pipeline
```

#### 1.2 Go inside and Run

```bash
cd react-aws-demo
npm start
```

#### 1.3 Then browse the following url:

```bash
http://localhost:3000
```


### 2. Create Dockerfile

#### 2.1 Inside project

```bash
Dockerfile
```


#### 2.2 Paste

```bash

FROM node:20

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm","start"]
```
#### 2.3 Create

```bash
.dockerignore
```


#### 2.4 Paste

```bash
node_modules
.git
```


### 3. Build Docker Image Locally

#### 3.1 Build docker image
```bash
docker build -t ci-cd-pipeline .
```

#### 3.2 Check
```bash
docker images
```

#### 3.3 Run the docker container "ci-cd-pipeline"

```bash
docker run -p 3000:3000 ci-cd-pipeline
```

#### 3.4 Visit:

```bash
http://localhost:3000
```

### 4. Create GitHub Repository

#### 4.1 Go to GitHub and create repository

```bash
platform-engineering-lab
```

#### 4.2 Initialize git

```bash
git init
git add .
git commit -m "Initial Commit"
```

#### 4.3 Connect repository
```bash
git remote add origin https://github.com/sanjoy-kumar/platform-engineering-lab.git
```

#### 4.4 Push
```bash
git push -u origin main
```


### 5. Launch EC2

#### 5.1 Create Ubuntu EC2:

```bash
Ubuntu 24.04
t2.micro
```

#### 5.2 Security Group:

```bash
22
80
443
```

#### 5.3 Download SSH key

```bash
key.pem
```


### 6. Connect EC2

#### 6.1 Windows PowerShell

```bash
ssh -i key.pem ubuntu@YOUR_PUBLIC_IP
ssh -i "openclaw-key.pem" ubuntu@ec2-3-133-84-26.us-east-2.compute.amazonaws.com
```

### 7. Update Server

```bash
sudo apt update
sudo apt upgrade -y
```

### 8. Install Git

#### 8.1 Install
```bash
sudo apt install git -y
```

#### 8.2 Check

```bash
git --version
```

### 9. Install Docker

#### 9.1 Install
```bash
sudo apt install docker.io -y
```

#### 9.2 Enable and Start Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

#### 9.3 Verify

```bash
docker --version
```
#### 9.4 Add current user:

```bash
sudo usermod -aG docker ubuntu
```

Logout
Reconnect


### 10. Clone GitHub Repository

#### 10.1 Clone the repository (one time)
```bash
git clone https://github.com/sanjoy-kumar/platform-engineering-lab.git
```

#### 10.2 Go inside

```bash
cd platform-engineering-lab
cd ci-cd-pipeline
```

## NB:  To automate deployments using GitHub Actions; don't follow steps 11 & 12(only for manuall deployment).  For CI/CD pipe line go to step 13. 

### 11. Build Docker Image on EC2

#### 11.1 Build
```bash
docker build -t ci-cd-pipeline .
```

#### 11.2 Check:

```bash
docker images
```

### 12. Run Container

#### 12.1 For development or local machine
```bash
docker run -d -p 80:3000 --name ci-cd-pipeline-app ci-cd-pipeline
```

#### 12.2 For production:

```bash
docker run -d -p 80:80 --name ci-cd-pipeline-app ci-cd-pipeline
```

#### 12.3 Check
```bash
docker ps
```

#### 12.4 Open browser

```bash
http://YOUR_PUBLIC_IP

http://3.133.84.26/
```



### 13. Auto Deployment using GitHub Actions


#### 13.1 Create an SSH Key for GitHub Actions

##### 13.1.1 On your local machine, generate a dedicated key pair:

```bash
ssh-keygen -t ed25519 -C "github-actions"
```

##### 13.1.2 Press Enter to accept the defaults, or specify a filename such as:

```json
github-actions
```

#### 13.2 Add the Public Key to EC2

##### 13.2.1 Display the public key from your local machine:

For Linux/Unix:

```bash
cat github-actions.pub
```

For wiindows:
```bash
Move-Item github-actions* C:\Users\sanjo\.ssh\
Get-Content $HOME\.ssh\github-actions.pub
```

##### 13.2.2 Copy the output

On the AWS EC2/GCP VM instance:

```bash
mkdir -p ~/.ssh
vim ~/.ssh/authorized_keys
```

Paste the copied public key, save, and exit.

##### 13.2.3 Set the correct permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 14. Test SSH Access

From your local machine:

```bash
ssh -i github-actions ubuntu@YOUR_EC2_IP
ssh -i $HOME\.ssh\github-actions ubuntu@ec2-18-225-173-114.us-east-2.compute.amazonaws.com
```

NB: If you can log in without a password, you're ready.


### 14. Configure GitHub Secrets

#### 14.1. Open your GitHub repository and Navigate to:


```json
Settings
    ↓
Secrets and variables
    ↓
Actions
```
https://github.com/sanjoy-kumar/platform-engineering-lab/settings/secrets/actions


#### 14.2 Create these repository secrets:

```json
Secret Name	Value
EC2_HOST	Your EC2 public IP
EC2_USER	ubuntu
EC2_SSH_KEY	Contents of the private github-actions key
```

```txt
For EC2_SSH_KEY, copy the entire private key, including:

-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```


### 15. Create the GitHub Actions Workflow


#### 15.1 Create:

```bash
.github/workflows/deploy.yml
```

#### 15.2 Add:
```yaml
name: Deploy React App

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Deploy to EC2
        uses: appleboy/ssh-action@v1.2.0

        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}

          script: |
            cd ~/react-aws-demo

            git pull origin main

            docker stop react-app || true
            docker rm react-app || true

            docker build -t react-demo .

            docker run -d \
              --name react-app \
              -p 80:80 \
              react-demo
```


### Useful Docker Commands

#### 1. Containers
```bash
docker ps
```
#### 2. All containers
```bash
docker ps -a
```
#### 3. Images
```bash
docker images
```
#### 4. Stop
```bash
docker stop react-app
```
#### 5. Start
```bash
docker start react-app
```
#### 6. Remove
```bash
docker rm react-app
```
#### 7. Logs
```bash
docker logs react-app
```
#### 8. Shell inside

```bash
docker exec -it react-app bash
```

### Executed all commands in the AWS EC2:

```bash
ubuntu@ip-172-31-43-16:~/platform-engineering-lab/ci-cd-pipeline$ history
    1  sudo apt update
    2  sudo apt upgrade -y
    3  sudo apt install git -y
    4  git --version
    5  sudo apt install docker.io -y
    6  sudo systemctl enable docker
    7  sudo systemctl start docker
    8  docker --version
    9  sudo usermod -aG docker ubuntu
   11  git clone https://github.com/sanjoy-kumar/platform-engineering-lab.git
   13  cd platform-engineering-lab/ci-cd-pipeline/
   15  logout
   > ssh -i "openclaw-key.pem" ubuntu@ec2-3-133-84-26.us-east-2.compute.amazonaws.com
   16  cd platform-engineering-lab/ci-cd-pipeline/
   17  docker build -t ci-cd-pipeline .
   19  docker images
   20  docker run -d -p 80:3000 --name ci-cd-pipeline-app ci-cd-pipeline
   21  docker ps
   23  docker stop ci-cd-pipeline-app
   25  docker start ci-cd-pipeline-app
   27  docker logs ci-cd-pipeline-app
ubuntu@ip-172-31-43-16:~/platform-engineering-lab/ci-cd-pipeline$

```

