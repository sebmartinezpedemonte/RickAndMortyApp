import { LightningElement, wire, track } from 'lwc';
import getCharacters from '@salesforce/apex/CharactersController.getCharacters';
import { NavigationMixin } from 'lightning/navigation';

export default class rickAndMortyCharactersList extends NavigationMixin(LightningElement) {
    @track characters = [];
    @track sortedBy;
    @track sortedDirection = 'asc';

    columns = [
        { label: 'External Id', fieldName: 'ExtId__c', type: 'number', sortable: true },
        { label: 'Name', fieldName: 'Name', type: 'button', sortable: true,
            typeAttributes: {label: { fieldName: 'Name' }, name:'view', target: '_self', variant: 'base'} },        
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Species', fieldName: 'Species__c', type: 'text' },
        { label: 'Gender', fieldName: 'Gender__c', type: 'text' },
        { label: 'Image URL', fieldName: 'ImageUrl__c', type: 'url' },
        { label : 'Image', fieldName: 'ImageUrl__c', type: 'image', 
            typeAttributes: {
                            url: { fieldName: 'ImageUrl__c' },
                            name: { fieldName: 'Name' } 
                            }
                        },
        { label: 'URL', fieldName: 'Url__c', type: 'url' },
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
