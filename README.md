# Build jenkins

Build Dockerfile
```
>docker build -t="bluemoon/jenlkins" .
```
Run docker image
```
>docker run -i -t -d -p 8080:8080 -p 2222:22 --name jenkins bluemoon/jenkins
```
you will check it ( Change IP for yours )
```
>docker ps
>ssh -p 2222 docker@192.168.33.10
```

## Jenkins on your blowser

watch browser http://192.168.33.10:8080/
