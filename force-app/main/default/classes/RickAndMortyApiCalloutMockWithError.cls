@isTest
global class RickAndMortyApiCalloutMockWithError implements HttpCalloutMock{

        global HTTPResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
		response.setBody('{"error": "Character not found"}');
        response.setStatusCode(404);
        return response;
    }
    
}