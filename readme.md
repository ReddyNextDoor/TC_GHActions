How to build & run:

docker build -t gha-runner:latest .

Then run interactively to configure:

docker run -it --rm gha-runner:latest config --url https://github.com/ReddyNextDoor/TC_GHActions --token YOUR_TOKEN_HERE

Then start runner:

docker run -it --rm gha-runner:latest run