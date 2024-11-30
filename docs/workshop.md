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
  - Guillaume David
contacts: # Required. Must match the number of authors
  - "@ikhemissi"
  - "@gdaCellenza"
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

For this Lab, we will focus on the following scope :

![image](/docs/assets/lab3-scope.jpg)

## 🚀 Part 1 : Expose an API (5 minutes)

In this first step, we will learn how to expose an API on Azure APIM. We will publish the API to fetch orders deployed in Lab 2.

<div class="task" data-title="Task">

1. Go the Azure APIM `ApimName`
2. On the left pane click on `APIS`
3. Then, click on `+ Add API` and on the group `Create from Azure resource` select the tile `Function App`

    ![image](/docs/assets/part1-step3.jpg)

4. In the window that opens :
    1. For the field `Function App`, click on `Browse`
    2. Then on the windows that opens : 
    3. On _Configure required settings_, click on `Select` and choose your ***Function App***

        ![image](/docs/assets/part1-step4_2.jpg)

    4. Be sure the function `FetchOrders` is select and click on `Select`

        ![image](/docs/assets/part1-step4_3.jpg)

5. Replace the values for the fields with the following values :
      - ***Display name***: `Orders API`
      - ***API URL suffix***: `orders`

6. Click on `Create`

✅ **Now the API is ready.** 

<div class="task" data-title="Task">

> Test it by clicking on the `Test` tab. On the displayed screen, select your operation and click on `Send`
>![image](/docs/assets/part1.jpg)

</div>

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## 🚀 Part 2 : Manage your API with Product (5 minutes)

Now the API is published, we will learn how to create a **Product** we will use to manage access and define usage plans.

<div class="task" data-title="Task">

1. On the APIM screen, in the menu on the left, click on `Products`, then click on `+ Add`.

    ![image](/docs/assets/part2-step1.jpg)

2. In the window that opens, fill in the fields with the following values and then click `Create`:
    - **Display name**: `Basic`
    - **Description**: Enter your description.
    - **Check the following boxes**:
      - `Published`
      - `Requires Subscription`

    ![image](/docs/assets/part2-step2.jpg)

3. Select the created product from the list and click on it.

4. On the next screen, click on `+ Add API`. In the right-hand menu that appears, select the API `Orders API` (the one create on the step 1) and then click `Select`.

    ![image](/docs/assets/part2-step4.jpg)

5. Select `Access control` from the menu on the left.
6. Click on `+ Add group`, then in the right-hand menu, select Developers before clicking on `Select`.

    ![image](/docs/assets/part2-step6.jpg)

7. Repeat steps 1 to 6 to create another product named `Premium`

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>


## 🚀 Part 3 : Securize your API (15 minutes)

Now that we have created our products, we will learn how to secure it. We will see two methods for this: Subscription Keys and the OAuth 2.0 standard.

### Subscription Key
-----------

We will below how create the subscription keys.

<div class="task" data-title="Task">

1. On the APIM screen, in the menu on the left, click on `Subscriptions`, then click on `+ Add subscription`.

    ![image](/docs/assets/part3_1-step1.jpg)


2. In the window that opens, fill in the fields with the following values and then click `Create`:
    - **Name**: `Basic-Subscription`
    - **Display name**: `Basic-Subscription`
    - **Scope**: `Product`
    - **Product**: `Basic`

    ![image](/docs/assets/part3_1-step2.jpg)

3. For the purpose of the part 4, repeat steps 1 and 2 to create another subscription linked to the product `Premium`, with the following fields value :
    - **Name**: `Premium-Subscription`
    - **Display name**: `Premium-Subscription`
    - **Scope**: `Product`
    - **Product**: `Premium`

Now that we have created two subscriptions, each corresponding to one of our products, we can view their values by right-clicking on them and selecting `Show/hide keys`

![image](/docs/assets/part3_1.jpg)

> Be sure to note down the values of your keys to use them in the tests we will perform.

</div>

<div class="task" data-title="Task">

We will know test our API with the subscription key.


> Before continuing, go back to the `Settings` of your API and make sure the `Subscription required` checkbox is checked.

1. On the APIM screen, in the menu on the left, click on APIs, then click on the `Orders API`.
2. Next, click on the `Test` tab and copy the value under `Request URL`.
3. Open Postman, create a new request, paste the value copied in the previous step, and click on `Send`.

    ![image](/docs/assets/part3_1_ResultF.jpg)

> 🔴 The result of this test is negative. A 401 Access Denied error is returned by the APIM. The error message states that the subscription key is missing.

4. In the Postman request, under the Headers tab, add the header `Ocp-Apim-Subscription-Key` and specify the value as the key retrieved during the creation of our subscription key. Then click on `Send`.

    ![image](/docs/assets/part3_1_ResultG.jpg)

> ✅ The call is now successful with a 200 OK response. 

</div>

### OAuth 2.0
-----------

<div class="task" data-title="Task">

We will now see how to securize our API with the OAuth 2.0 standard

1. On the APIM screen, in the menu on the left, click on APIs, then click on the `Orders API`.
2. Go to `All operations`. On the right, in the `Inbound processing` section, click on the `</>` icon to access the policy editing mode.

    ![image](/docs/assets/part3_2-step2.jpg)

3. In the `<inbound>` section and under the `<base />` tag, add the following code and click on `Save`

```xml

  <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Access token is missing or invalid." require-scheme="Bearer">
            <openid-config url="https://login.microsoftonline.com/{{tenant}}/.well-known/openid-configuration" />
            <issuers>
                <issuer>https://login.microsoftonline.com/{{tenant}}/v2.0</issuer>
                <issuer>https://sts.windows.net/{{tenant}}/</issuer>
            </issuers>
        </validate-jwt>

```
  ![image](/docs/assets/part3_2-step3.jpg)

</div>

<div class="task" data-title="Task">

We will now see how to test our API securized by the OAuth 2.0 standard

1. Open Postman, on our previous request and click on `Send`.

    ![image](/docs/assets/part3_2_ResultF.jpg)

> 🔴 The API Manager returns a 401 error. Indeed, it is now necessary to pass the token in order to be authorized to call the API.

2. On PostMan, create a new request with the following information
    - Method : POST
    - Url : `https://login.microsoftonline.com/{{tenant}}/oauth2/v2.0/token`
      **TBD : how we get the tenant ??**
    - Under the Headers tab, choose the option x-www-form-urlencoded and add the following attributes with the values :
        -**grant_type**: client_credentials
        -**client_id**: **TBD**
        -**client_secret**:**TBD**
        -**scope**: **TBD**/.defaut
    - Click on Send
    - Retrieve the `access_token` returned by the identity provider.

    ![image](/docs/assets/part3_2_ResultToken.jpg)

3. Go back to the `FetchOrders` request.
4. In the `Authorization` section, choose in the `Auth Type` list the value `Bearer Token` and copy/paste the value retrieved in step 2.

5. Send the request and observe the result.

    ![image](/docs/assets/part3_2_ResultG.jpg)

> ✅ The Orders API is now secured using the OAuth 2.0 framework!

</div>


<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

## 🚀 Part 4 : Change the behaviour of your API with APIM Policies (15 minutes)

In this final part of the lab, we will learn how to apply APIM policies to dynamically customize API behavior.

### Rate Limiting
-----------

<div class="task" data-title="Task">

To begin, we will set a limit for the Basic user to ensure they cannot call our API more than 5 times per minute.

1. On the APIM screen, in the menu on the left, click on `Products`, then select the product `Basic` from the list and click on it.
2. Go to `Policies`. On the right, in the `Inbound processing` section, click on the `+ Add policy` access the policy catalog.

    ![image](/docs/assets/part4_1-step2.jpg)

3. Click on the tile `rate-limit-by-key`
4. In the window that opens, fill in the fields with the following values and then click `Save`:
    - **Number of calls**: `5`
    - **Renewal period**: `60`
    - **Counter Key**: `API subscription`
    - **increment condition**: `Any request`

    ![image](/docs/assets/part4_1-step4.jpg)

5. Go back to Postman and run about ten closely spaced tests.

> Make sure to test using the subscription key corresponding to the `Basic` product.

![image](/docs/assets/part4_1-Result.jpg)

>💡After the first 5 calls, subsequent calls are blocked. After 1 minutes, calls become possible again.

</div>

<details>

<summary> Toggle solution</summary>

TODO: provide solution

</details>

### Monetize API
-----------

<div class="task" data-title="Task">

To conclude, we will simulate the monetization of an API using a custom policy that we will now implement.

1. On the APIM screen, in the menu on the left, click on `Products`, then select the product `Premium` from the list and click on it.
2. Go to `All operations`. On the right, in the `Inbound processing` section, click on the `</>` icon to access the policy editing mode.

![image](/docs/assets/part4_2-step2.jpg)

3. In the `<inbound>` section and under the `<base />` tag, add the following code and click on `Save`

```xml

<set-variable name="creditValue" value="{{credit}}" />
        <!-- Check if the credit value is greater than 0 -->
        <choose>
            <when condition="@(int.Parse((string)context.Variables.GetValueOrDefault("creditValue")) > 0)">
                <set-variable name="newCreditValue" value="@(int.Parse((string)context.Variables.GetValueOrDefault("creditValue")) - 1)" />
                <send-request mode="new" response-variable-name="credit" timeout="60" ignore-error="false">
                    <set-url>https://management.azure.com/subscriptions/{{subscription}}/resourceGroups/{{resourcegroup}}/providers/Microsoft.ApiManagement/service/{{apim}}/namedValues/credit?api-version=2024-05-01</set-url>
                    <set-method>PATCH</set-method>
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body template="liquid">
                    {
                        "properties": {
                        "value": "{{context.Variables["newCreditValue"]}}"
                        }
                    }
                    </set-body>
                    <authentication-managed-identity resource="https://management.azure.com" />
                </send-request>
            </when>
            <otherwise>
                <return-response>
                    <set-status code="429" reason="Too Many Requests" />
                    <set-header name="Content-Type" exists-action="override">
                        <value>application/json</value>
                    </set-header>
                    <set-body>{"error": {"code": "CREDIT_LIMIT_EXCEEDED","message": "Your credit limit is insufficient. Please check your account or contact support."}}</set-body>
                </return-response>
            </otherwise>
        </choose>

```

4. On the APIM screen, in the menu on the left, click on `Named values`, then ensure that the value of the named value `Credit` is set to `0`.
5. Go back to Postman and run a test

    ![image](/docs/assets/part4_2-ResultF.jpg)

>🔴 The API Manager returns a 429 error. Indeed, the credit value is 0 so we don't have credit to make API request.

6. Go back on the APIM screen, in the menu on the left, click on `Named values`, then select the named value `Credit` from the list and click on it and set the Value to `1` and click on `Save`.

    ![image](/docs/assets/part4_2-step5.jpg)

7. Go back to Postman and run about a test and observe the result.

    ![image](/docs/assets/part4_2-ResultG.jpg)

> ✅ Now we have credit, so the call is successful.

<div class="tip" data-title="Tip">

You can run another test to use up all your credit and observe the result.

</div>


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
