const { app, output } = require('@azure/functions');

// const serviceBusOutput = output.serviceBusQueue({
//     queueName: '%SERVICEBUS_QUEUE%',
//     connection: 'SB_ORDERS',
// });

app.cosmosDB('QueueOrders', {
    databaseName: '%COSMOS_DB_DATABASE_NAME%',
    containerName: '%COSMOS_DB_TO_PROCESS_CONTAINER_NAME%',
    leaseContainerName: '%COSMOS_DB_LEASES_CONTAINER_NAME%',
    connection: 'COSMOS_DB',
    // return: serviceBusOutput,
    handler: (orders, context) => {
        context.log(`Queueing ${orders.length} orders to process`);
        context.log(`Orders: ${JSON.stringify(orders)}`);
        return orders;
    },
});
