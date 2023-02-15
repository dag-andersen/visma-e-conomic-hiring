# dummy-pdf-or-png
Pseudorandomly returns either a pdf or png file.

Responds to GET requests on "/" port 3000.

Dockerfile multi-stage takes care of building, so to get started you run the 
following commands in this directory, assuming you have Docker installed.

```bash
make build run 
# Optionally
docker build -t dummy-pdf-or-png .
docker run --rm -it -p 3000:3000 dummy-pdf-or-png
```

On purpose, the service will sometimes deliver a corrupt pdf file.
