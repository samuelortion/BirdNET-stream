import { Controller } from '@hotwired/stimulus';

/* stimulusFetch: 'lazy' */
export default class extends Controller {
    static targets = ['filename']

    delete() {
        let filename = this.filenameTarget.value;
        let url = `/records/delete/${filename}`;
        fetch(url, {
            method: 'POST'
        })
        .then(response => {
            if (response.ok) {
                window.location.reload();
            } else {
                console.log(response);
            }
        })
        .catch(error => {
            console.log(error);
        }
        );
    }
}