@IsTest
private class WhatsAppWebhookHandlerTest {

    @IsTest
    static void testVerifyEndpoint() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.addParameter('hub.mode', 'subscribe');
        req.addParameter('hub.verify_token', 'dhruv_hackathon_2026');
        req.addParameter('hub.challenge', 'abc123');
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        WhatsAppWebhookHandler.doGet();

        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals('abc123', RestContext.response.responseBody.toString());
    }

    @IsTest
    static void testInvalidVerifyToken() {
        RestRequest req = new RestRequest();
        req.httpMethod = 'GET';
        req.addParameter('hub.mode', 'subscribe');
        req.addParameter('hub.verify_token', 'wrong');
        req.addParameter('hub.challenge', 'abc123');
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        WhatsAppWebhookHandler.doGet();

        System.assertEquals(403, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostNoMatchingRecipient() {
        // No Demo_Recipients__mdt for this phone — handler returns early, no exception
        String body = '{"object":"whatsapp_business_account","entry":[{"id":"123","changes":[{"value":{"messaging_product":"whatsapp","messages":[{"from":"919000000000","type":"text","text":{"body":"Yes call in 30 mins"}}]}}]}]}';
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WhatsAppWebhookHandler.doPost();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostNonTextMessage() {
        String body = '{"object":"whatsapp_business_account","entry":[{"id":"123","changes":[{"value":{"messaging_product":"whatsapp","messages":[{"from":"919876543210","type":"image","image":{}}]}}]}]}';
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf(body);
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        WhatsAppWebhookHandler.doPost();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
    }

    @IsTest
    static void testPostEmptyPayload() {
        RestRequest req = new RestRequest();
        req.httpMethod  = 'POST';
        req.requestBody = Blob.valueOf('{"object":"whatsapp_business_account","entry":[]}');
        RestContext.request  = req;
        RestContext.response = new RestResponse();

        WhatsAppWebhookHandler.doPost();
        System.assertEquals(200, RestContext.response.statusCode);
    }
}
