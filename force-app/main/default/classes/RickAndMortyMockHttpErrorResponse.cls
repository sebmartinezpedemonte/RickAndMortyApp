@isTest
global class RickAndMortyMockHttpErrorResponse implements HttpCalloutMock{
    
    global HttpResponse respond(HttpRequest request){
        throw new CalloutException('Simulacion de un callout exception');
    }
}