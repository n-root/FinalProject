# Start from the rstudio/plumber image
FROM rocker/r-ver:4.3.2

# Install the linux libraries needed for plumber
RUN apt-get update -qq && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install plumber, GGally
RUN R -e "install.packages(c('plumber', 'caret', 'randomForest'), repos='http://cran.rstudio.com/')"

# Copy API into the container
COPY API.R API.R
COPY diabetes_binary_health_indicators_BRFSS2015.csv diabetes_binary_health_indicators_BRFSS2015.csv 

# Open port to traffic
EXPOSE 8000

# When the container starts, start the API.R script
ENTRYPOINT ["R", "-e", \
    "pr <- plumber::plumb('API.R'); pr$run(host='0.0.0.0', port=8000)"]