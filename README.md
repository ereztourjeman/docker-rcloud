#Docker-RCloud
A barebone implementation of RCloud is available through the Docker-RCloud project. This Dockerfile currently build an RCloud instance based on the following stack
* RCloud version [0.9](https://github.com/att/rcloud/releases/tag/0.9)
* R version 3.0.2

## Getting Started
Docker commands have been bootstrapped, which makes it slightly easier to develop. It's easy to get started - 

#### 1. Register a github application.
You'll need to create a [github application](https://github.com/settings/applications). Go ahead, open the link and click on "Register New Application" on the top right corner. 

Please provide the follwing details in the application registration form 

    Application Name: RCloud
    Homepage URL: http://127.0.0.1:8080/login.R
    Callback URL: http://127.0.0.1:8080/login_successful.R
        

This github application will need to point to the location you will deploy rcloud (`RCLOUD_BASE_URL`, or in this case `127.0.0.1`). 
Please make a note of your client id and client secret the application is registered.

#### 2. Edit `rcloud.conf`. 
 If you're using github.com, then your file will look like this:

    github.client.id: your.20.character.client.id
    github.client.secret: your.40.character.client.secret
    github.base.url: https://github.com/
    github.api.url: https://api.github.com/

#### 3. Build the docker image
Simply do 
    ./build

#### 4. Run the docker instance
All necessary ports are already forwarded. This means that all you need to do is
    ./run

### Optional
Additional docker commands have been bootstrapped as well
#### Stop all containers
    ./stop-all
#### Login to the running container
    ./login-container
#### Login to the image
    ./login-image
#### Rebuild, run and login into the container
    ./bootstrap

