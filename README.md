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



