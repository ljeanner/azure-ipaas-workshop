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

For this Lab, we will focus on the following scope :

![image](/docs/assets/24ba989b-5d4c-4bb6-9f9b-ec9a1175b8f0.jpg)

## Step1 : Expose an API (5 minutes)

In this first step, we will learn how to expose an API on Azure APIM. We will publish the API to fetch orders deployed in Lab 2.

<div class="task" data-title="Task">

- Go the Azure APIM `ApimName`
- On the left pane click on `APIS`
- Then, click on `+ Add API` and on the group `Create from Azure resource` select the tile `Function App`

**Add a screenshot**

- In the window that opens :
  - For the field `Function App`, click on `Browse`
  - Then on the windows that opens : 
    - On _Configure required settings_, click on `Select` and choose your ***Function App***

      **Add a screenshot**

    - Be sure the function `FetchOrders` is select and click on select

      **Add a screenshot**

  - Replace the values for the fields with the following values :
    - ***Display name***: `Orders API`
    - ***API URL suffix***: `orders`
  - Click on `Create`

✅ **Now the API is ready.** 

<div class="task" data-title="Test">

> Test it by clicking on the `Test` tab. On the displayed screen, select your operation and click on `Send`
>**Add a screenshot**

</div>

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Step2 : Manage your API with Product (10 minutes)

<div class="task" data-title="Task">

> - TODO: first task

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Step3 : Securize your API (10 minutes)

On your API Order

<div class="task" data-title="Task">

> - TODO: first task

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Step 4 : Change the behaviour of your API with APIM Policies (15 minutes)

<div class="task" data-title="Task">

> - TODO: first task

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## Lab 3 : Summary

In this lab, we learn how to use Azure APIM in a four-step process:

1. **Expose an API:** Understand how to publish APIs on the Azure APIM platform, enabling seamless integration and accessibility for external and internal consumers.
2. **Manage Your API with Products:** Organize APIs into products to streamline access and define usage plans, making API consumption structured and manageable.
3. **Secure Your API:** Implement robust security measures, including subscription keys for controlled access and OAuth for modern authentication and authorization.
4. **Modify API Behavior Using Policies:** Explore the policy catalog and apply APIM policies to dynamically customize API behavior, by implementing rate limiting. Additionally, create a custom policy through a use case focused on monetizing APIs.

---

# Closing the workshop

Once you're done with this lab you can delete all the resources which you have created at the beginning using the following command:

```bash
azd down
```
