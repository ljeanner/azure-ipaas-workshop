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

# Lab 2 : Sync and async patterns with Azure Functions and Service Bus (45m)

In the previous lab, we have added orders to CosmosDB.
In this lab, we will focus on processing and fetching these orders by implementing 2 workflows:
- Processing orders asynchronously using Azure Functions and Service Bus
- Fetching and serving order synchronously va HTTP using Azure Functions

TODO DRAFT: Introduce Azure Functions and Service Bus in 1-line each.

## Queueing orders in Service Bus

TODO DRAFT: describe the need for async operations and the resiliency we get with a message broker like Service Bus including operation retries.

The data processing function app (with a name starting with `func-proc-lab`) should already have 2 functions deployed `QueueOrders` and `ProcessOrders`.

<div class="task" data-title="Task">

> - Update the `QueueOrders` function to queue messages in Service Bus for every new document in CosmosDb

</div>

<div class="tip" data-title="Tips">

> - You can use the environment variables `SERVICEBUS_QUEUE`, and `SB_ORDERS__fullyQualifiedNamespace` to send messages to Service Bus using the managed identity of the Function App `func-proc-lab-<SUFFIX>`
>
> - You can leverage the [Service Bus output binding](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-output?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-javascript)
</div>

<details>

<summary> Toggle solution</summary>

In the file `src/dataprocessing/src/functions/QueueOrders.js`, uncomment the lines 3 to 6, and line 13 by removing `//` from each line beginning.

Your code should look like:

```js
const { app, output } = require('@azure/functions');

const serviceBusOutput = output.serviceBusQueue({
    queueName: '%SERVICEBUS_QUEUE%',
    connection: 'SB_ORDERS',
});

app.cosmosDB('QueueOrders', {
    databaseName: '%COSMOS_DB_DATABASE_NAME%',
    containerName: '%COSMOS_DB_TO_PROCESS_CONTAINER_NAME%',
    connection: 'COSMOS_DB',
    createLeaseContainerIfNotExists: true,
    return: serviceBusOutput,
    handler: (orders, context) => {
        context.log(`Queueing ${orders.length} orders to process`);
        context.log(`Orders: ${JSON.stringify(orders)}`);
        return orders;
    },
});
```

Once you have updated the code, re-deploy the Function App code to get your updates running on Azure:

```sh
azd deploy dataprocessing
```

</details>

Once you have deployed your updated Function App, you need to test your new changes by retriggering the data ingestion workflow with Logic Apps.

<div class="task" data-title="Task">

> - Please head to the Azure Portal, retest your logic app and make sure `QueueOrders` is queueing a message in Service Bus.

</div>

<details>

<summary> Toggle solution</summary>

Locate your data processing Function App (name starting with `func-proc-lab`), click on the function `ProcessOrders`, and check the `Invocations` tab.

You should see a new recent invocation (this may take a while).

Check the logs of the invocation to get more details. 

</details>

## Processing orders

In this step, we will update the `ProcessOrders` function to process orders while being able to retry automatically if order processing fails.

<div class="task" data-title="Task">

> - Update the `ProcessOrders` function to store processed orders retrieved from Service Bus in CosmosDB

</div>

<div class="tip" data-title="Tips">

> - You can use the environment variables `COSMOS_DB_DATABASE_NAME`, `COSMOS_DB_PROCESSED_CONTAINER_NAME`, and `COSMOS_DB__accountEndpoint` to send messages to Service Bus using the managed identity of the Function App `func-proc-lab-<SUFFIX>`
>
> - You can leverage the [CosmosDB output binding](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-cosmosdb-v2-output?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv4&pivots=programming-language-javascript)
</div>

<details>

<summary> Toggle solution</summary>

In the file `src/dataprocessing/src/functions/ProcessOrders.js`, uncomment the lines 3 to 7, and line 12 by removing `//` from each line beginning.

Your code should look like:

```js
const { app, output } = require('@azure/functions');

const cosmosOutput = output.cosmosDB({
    databaseName: '%COSMOS_DB_DATABASE_NAME%',
    containerName: '%COSMOS_DB_PROCESSED_CONTAINER_NAME%',
    connection: 'COSMOS_DB',
});

app.serviceBusQueue('ProcessOrders', {
    queueName: '%SERVICEBUS_QUEUE%',
    connection: 'SB_ORDERS',
    return: cosmosOutput,
    handler: async (order, context) => {
        context.log(`Order to process: ${JSON.stringify(order)}`);

        const processedOrder = {
            ...order,
            status: 'processed',
            processedAt: new Date().toISOString(),
        };

        context.log(`Processed order: ${JSON.stringify(processedOrder)}`);

        return processedOrder;
    },
});
```

Once you have updated the code, re-deploy the Function App code to get your updates running on Azure:

```sh
azd deploy dataprocessing
```

</details>

Now that you have implemented the full order processing pipeline, you will need to test it and make sure everything works.

<div class="task" data-title="Task">

> - Please head to the Azure Portal, retest your logic app and make sure `ProcessOrders` is writing orders in the `processed` container in CosmosDB.

</div>

<details>

<summary> Toggle solution</summary>

Re-test your Logic App, then go to CosmosDB, and locate the `processed` container.

You should be able to see new entries with the test data which you have used with Logic Apps.

</details>

## Fetch and serve orders

In addition to reacting to events (e.g. message in Service Bus), Azure Functions also allows you to implement APIs and serve HTTP requests.

In this last exercice of Lab2, you need to update the data fetching Function App (with a name starting with `func-ftch-lab`) to have the `FetchOrders` return the latest processed orders.

<div class="task" data-title="Task">

> - Update the `FetchOrders` function to fetch the latest processed orders from CosmosDB.

</div>

<div class="tip" data-title="Tips">

> - You can leverage the data returned from the [CosmosDB input binding](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-output?tabs=python-v2%2Cisolated-process%2Cnodejs-v4%2Cextensionv5&pivots=programming-language-javascript)
</div>

<details>

<summary> Toggle solution</summary>

In the file `src/datafetching/src/functions/FetchOrders.js`, uncomment the line 18 by removing `//` from the line beginning.

Your code should look like:

```js
const { app, input } = require('@azure/functions');

const cosmosInput = input.cosmosDB({
    databaseName: '%COSMOS_DB_DATABASE_NAME%',
    containerName: '%COSMOS_DB_CONTAINER_NAME%',
    connection: 'COSMOS_DB',
    sqlQuery: 'SELECT * FROM c ORDER BY c._ts DESC OFFSET 0 LIMIT 50',
});

app.http('FetchOrders', {
    methods: ['GET'],
    authLevel: 'anonymous',
    extraInputs: [cosmosInput],
    handler: async (request, context) => {
        let orders = [];
        context.log('Fetching orders...');

        orders = context.extraInputs.get(cosmosInput);

        context.log(`Found ${orders?.length} orders...`);

        return {
            jsonBody: orders,
        };
    }
});
```

Once you have updated the code, re-deploy the Function App code to get your updates running on Azure:

```sh
azd deploy datafetching
```

</details>

Once you have deployed your updated Function App, you need to test your new changes by calling the HTTP endpoint of `FetchOrders`.

<div class="task" data-title="Task">

> - Call the HTTP endpoint of `FetchOrders` and make sure it returns the latest processed orders.

</div>

<details>

<summary> Toggle solution</summary>

TODO: describe how to get the url of the function and how to call it

</details>

## Lab 2 : Summary

TODO: describe what the attendee has learned in this lab sync and async flows with functions and service bus.

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
