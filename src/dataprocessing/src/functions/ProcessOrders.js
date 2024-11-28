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