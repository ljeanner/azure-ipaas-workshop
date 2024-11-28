---
published: true
type: workshop
title: Build an event-driven data processing application using Azure iPaaS services
short_title: Event-driven application using Azure iPaaS
description: In this workshop you will learn how to build an event-driven application which will process e-commerce orders. You will leverage Azure iPaaS services to prepare, queue, process, and serve data.
level: intermediate # Required. Can be 'beginner', 'intermediate' or 'advanced'
navigation_numbering: false
authors: # Required. You can add as many authors as needed
  - Iheb Khemissi
contacts: # Required. Must match the number of authors
  - "@ikhemissi"
duration_minutes: 180
tags: azure, ipaas, functions, logic apps, apim, service bus, event grid, entra, cosmosdb, codespace, devcontainer, innovation day
navigation_levels: 3

---

# Build an event-driven data processing application using Azure iPaaS services

Welcome to this Azure iPaaS Workshop. You'll be experimenting with multiple integration services to build an event-driven data processing application.

You should ideally have a basic understanding of Azure, but if not then do not worry, you will be guided through the whole process.

During this workshop you will have the instructions to complete each steps. The solutions are placed under the 'Toggle solution' panel.

<div class="task" data-title="Task">

> - You will find the instructions and expected configurations for each Lab step in these yellow **TASK** boxes.
> - Log into your Azure subscription on the [Azure Portal][az-portal] using the credentials provided to you.

</div>


## Scenario

TODO: describe a business scenarion around order processing

## Tooling and services

TODO: provide a 1-line description for iPaaS services + azd + codespaces 

## Prepare your dev environment

TODO: describe how to fork the project, start Github Codespaces, and log into Azure via azd.

### Provision resources in Azure

<div class="task" data-title="Task">

> - Use `azd` to provision resources in Azure and deploy provided applications

</div>

<details>

<summary> Toggle solution</summary>

```sh
# Log into azd
azd auth login

# Provision resources and deploy applications
azd up
```

</details>


### Validate the setup on Azure

The provisioning step may take few minutes. Once it finishes you should have a resource group containing all resources needed in this workshop.

Moreover, you some of the applications (e.g. Azure Functions) should also be deployed and ready to be used.

<div class="task" data-title="Task">

> - Open the Azure Portal and ensure that you can see a resource group with various iPaaS resources
> - Ensure that there are no failed deployments

</div>

<details>

<summary> Toggle solution</summary>

TODO: describe how to check the above with a screenshot or a command line to run in GH codespaces

</details>

---

# Lab 1 : Processing data with Logic Apps (45m)

TODO: intro

## Step1 (TBD)

<div class="task" data-title="Task">

> - TODO: first task

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Lab 1 : Summary

TODO: describe what the attendee has learned in this lab

---

# Lab 2 : Sync and async patterns with Azure Functions (45m)

TODO: intro

## Step1 (TBD)

<div class="task" data-title="Task">

> - TODO: first task

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Lab 2 : Summary

TODO: describe what the attendee has learned in this lab

---

# Lab 3 : Exposing and monetizing APIs (45m)

TODO: intro

## Step1 (TBD)

<div class="task" data-title="Task">

> - TODO: first task

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Lab 3 : Summary

TODO: describe what the attendee has learned in this lab


---

# Closing the workshop

Once you're done with this lab you can delete all the resources which you have created at the beginning using the following command:

```bash
azd down
```
