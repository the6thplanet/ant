# Use official Python image as base
FROM python:3.9

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory in container
WORKDIR /code


# Copy project files to the container
COPY ./src/app_v1.py /code/

# Expose the port the app runs on
EXPOSE 8000

# Run app
CMD ["python", "app_v1.py", "runserver", "0.0.0.0:8000"]
