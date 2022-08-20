import { Controller } from '@hotwired/stimulus';
import { delete_record } from '../utils/delete';

/* stimulusFetch: 'lazy' */
export default class extends Controller {
    static targets = ['filename']
    delete() {
        let filename = this.filenameTarget.value;
        delete_record(filename);
    }
}