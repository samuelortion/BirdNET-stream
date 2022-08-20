const axios = require('axios').default;

import { Controller } from '@hotwired/stimulus';
import { delete_record } from '../utils/delete';


/* stimulusFetch: 'lazy' */
export default class extends Controller {

    static targets = ['current'];

    mark_as_verified() {
        let selected = this.currentTarget.value;
        let url = `/records/manage/verify/${selected}`;
        axios.post(url)
            .then(function (response) {
                console.log(response);
            }
            ).catch(function (error) {
                console.error(error);
            }
            );
            
    }

    select_all() {
        let selected = document.querySelectorAll(".select-record");
        selected.forEach(function (item) {
            item.checked = true;
        });
    }

    delete_selected() {
        let selected = document.querySelectorAll(".select-record:checked");
        if (selected.length > 0) {
            // confirm delete
            if (confirm("Are you sure you want to delete these records?")) {
                // delete
                for (let file of selected) {
                    delete_record(file.value);
                }
            }
        }
    }
}