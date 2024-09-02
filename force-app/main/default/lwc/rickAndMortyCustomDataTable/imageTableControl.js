import { LightningElement, api } from 'lwc';

export default class ImageTableControl extends LightningElement {
    @api url;
    @api name;

    get altText() { 
        return "Imagen de " + this.name;
    }
    
}
