# DevOps Technical Task

## Overview

This technical task allows you to demonstrate your DevOps skills! The exercise should take no more than a weekend to complete. If you need any clarification, please don't hesitate to ask us.

## Task Details

This repository contains a simple .NET service that serves a single endpoint: `/count`. Each call to this endpoint increments a counter and returns the number of times the endpoint has been called.

We'd like to deploy this application using an automated process with [Azure Pipelines](https://learn.microsoft.com/en-us/azure/devops/pipelines/?view=azure-devops).

The CI pipeline should include the following steps:

1. Test the application by running `dotnet test`
2. Build the application by running `dotnet build`
3. Publish the application using docker or as an artifact.

The CD pipeline should:

1. Be automatically triggered when the CI build completes successfully
2. You can assume that the infrastructure already exists, the requirement is just to deploy the application.
3. If wish to test & don't want to be billed, an azure app service offers a free tier.

In your solution, include a readme detailing your thought process and any design decisions you made.

## Requirements

- Solution pushed to a public GitHub/Azure repository
- Valid `azure-build.yml` CI pipeline containing `test`, `build`, and `publish` steps.
- Valid `azure-release.yml` CD pipeline to deploy the solution to an azure application of your choice.
- The CI and CD should be implemented as two separate pipelines
- Include best practices for PR workflows, CI & CD triggers, and approval gates in your solution

If you have any questions, please do not hesitate to ask!
