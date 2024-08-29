@isTest
global class RickAndMortyApiCalloutMock implements HttpCalloutMock{
    
    global HTTPResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"id": 1, "name": "Rick Sanchez", "status": "Alive", "species": "Human", "gender": "Male", "image": "https://rickandmortyapi.com/api/character/avatar/1.jpeg", "url": "https://rickandmortyapi.com/api/character/1"}');
        response.setStatusCode(200);
        return response;
    }

}