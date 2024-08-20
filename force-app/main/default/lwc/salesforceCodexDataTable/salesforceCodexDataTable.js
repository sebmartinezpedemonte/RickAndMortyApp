
import LightningDatatable from 'lightning/datatable';
import imageTableControl from './imageTableControl.html';
import NewValue from '@salesforce/schema/AccountHistory.NewValue';

export default class SalesforceCodexDataTable extends LightningDatatable  {
    static customTypes = {
        image: {
            template: imageTableControl
        }
    };

    

}