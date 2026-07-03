# platform-engineering-lab

### Create React App

```bash
npx create-react-app ci-cd-pipeline
```

```bash
cd react-aws-demo
npm start
```

Then browse it:

```txt
http://localhost:3000
```


### Create Dockerfile

Inside project

```txt
Dockerfile
```

### Create

```txt
.dockerignore
```

### Build Docker Image Locally
```bash
docker build -t ci-cd-pipeline .
```
### Run ci-cd-pipeline 

```bash
docker run -p 3000:3000 ci-cd-pipeline
```

Visit:

```bash
http://localhost:3000
```

### Create GitHub Repository

Go to GitHub and create repository

```bash
ci-cd-pipeline
```

Initialize git

```bash
git init
git add .
git commit -m "Initial Commit"
```

Connect repository
```bash
git remote add origin https://github.com/YOUR_USERNAME/ci-cd-pipeline.git
```

Push
```bash
git push -u origin main
```


### Launch EC2

Create Ubuntu EC2:

```bash
Ubuntu 24.04
t2.micro
```

Security Group:

```bash
22
80
443
```

Download

```bash
key.pem
```


### Connect EC2

Windows PowerShell

```bash
ssh -i key.pem ubuntu@YOUR_PUBLIC_IP
```

### Update Server

```bash
sudo apt update
sudo apt upgrade -y
```

### Install Git
```bash
sudo apt install git -y
```
Check

```bash
git --version
```

### Install Docker

```bash
sudo apt install docker.io -y
```

Start Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

Verify

```bash
docker --version
```

Add current user:

```bash
sudo usermod -aG docker ubuntu
```

Logout
Reconnect


### Clone GitHub Repository

```bash
git clone https://github.com/YOUR_USERNAME/ci-cd-pipeline.git
```
Go inside

```bash
cd ci-cd-pipeline
```

### Build Docker Image on EC2

```bash
docker build -t ci-cd-pipeline .
```

Check:

```bash
docker images
```

### Run Container

```bash
docker run -d -p 80:3000 --name ci-cd-pipeline-app ci-cd-pipeline
```

For production:

```bash
docker run -d -p 80:80 --name ci-cd-pipeline-app ci-cd-pipeline
```

Check
```bash
docker ps
```


Open browser

```bash
http://YOUR_PUBLIC_IP

http://3.133.84.26/
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

