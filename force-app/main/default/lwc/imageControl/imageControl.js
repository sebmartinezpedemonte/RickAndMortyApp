import { LightningElement, api } from 'lwc';

export default class ImageControl extends LightningElement {
    @api url;
    @api altText;

    renderedCallback() {
        console.log('Recibi altText en ImageControl:', this.altText);
    }
}
