import LightningDatatable from 'lightning/datatable';
import imageTableControl from './imageTableControl.html';

export default class rickAndMortyCustomDataTable extends LightningDatatable {
    static customTypes = {
        image: {
            template: imageTableControl,
            typeAttributes: ['url', 'name'], 
        }
    }
}

