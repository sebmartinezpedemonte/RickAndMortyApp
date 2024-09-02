import { LightningElement, wire, track } from 'lwc';
import getCharacters from '@salesforce/apex/CharactersController.getCharacters';
import { NavigationMixin } from 'lightning/navigation';
import FIELD_NAME from '@salesforce/schema/Personaje__c.Name';
import FIELD_STATUS from '@salesforce/schema/Personaje__c.Status__c';
import FIELD_SPECIES from '@salesforce/schema/Personaje__c.Species__c';
import FIELD_GENDER from '@salesforce/schema/Personaje__c.Gender__c';
import FIELD_IMAGE from '@salesforce/schema/Personaje__c.ImageUrl__c';
import FIELD_URL from '@salesforce/schema/Personaje__c.Url__c';
import FIELD_EXTID from '@salesforce/schema/Personaje__c.ExtId__c';

export default class rickAndMortyCharactersList extends NavigationMixin(LightningElement) {
    @track characters = [];
    @track sortedBy;
    @track sortedDirection = 'asc';

    columns = [
        { label: 'External Id', fieldName: FIELD_EXTID.fieldApiName, type: 'number', sortable: true },
        { label: 'Name', fieldName: FIELD_NAME.fieldApiName, type: 'button', sortable: true,
            typeAttributes: {label: { fieldName: FIELD_NAME.fieldApiName }, name:'view', target: '_self', variant: 'base'} },        
        { label: 'Status', fieldName: FIELD_STATUS.fieldApiName, type: 'text' },
        { label: 'Species', fieldName: FIELD_SPECIES.fieldApiName, type: 'text' },
        { label: 'Gender', fieldName: FIELD_GENDER.fieldApiName, type: 'text' },
        { label: 'Image URL', fieldName: FIELD_IMAGE.fieldApiName, type: 'url' },
        { label : 'Image', fieldName: FIELD_IMAGE.fieldApiName, type: 'image', 
            typeAttributes: {
                            url: { fieldName: 'ImageUrl__c' },
                            name: { fieldName: FIELD_NAME.fieldApiName } 
                            }
                        },
        { label: 'URL', fieldName: FIELD_URL.fieldApiName, type: 'url' },
    ];

    @wire(getCharacters)    
    wiredCharacters({ error, data }) {
        if (data) {
            this.characters = data.map(character=>{
                return{
                    ...character,
                    recordLink: `/${character.Id}`
                };

            });        
        } else if (error) {
            console.error('Error:', error);
        }
    }
    
    handleSort(event) {        
        const sortedBy = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const cloneData = [...this.characters];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.characters = cloneData;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
    }





sortBy(field, reverse) {
    return (a, b) => {
        let valueA = a[field];
        let valueB = b[field];
        
        // Verifica si los valores son numeros
        if (!isNaN(valueA) && !isNaN(valueB)) {
            valueA = parseFloat(valueA);
            valueB = parseFloat(valueB);
        } else {
            valueA = valueA ? valueA.toLowerCase() : '';
            valueB = valueB ? valueB.toLowerCase() : '';
        }

        return reverse * ((valueA > valueB) - (valueB > valueA));
    };
}
    

    handleRowAction(event) {
        const row = event.detail.row;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Personaje__c',
                actionName: 'view'
            },
        });
    }
}
