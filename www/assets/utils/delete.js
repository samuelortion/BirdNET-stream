const axios = require('axios').default;

function delete_record(filename) {
    let url = `/records/delete/${filename}`;
    axios.post(url)
        .then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.error(error);
        });
}

function delete_records(filenames) {
    let url = "/records/delete/all";
    axios.post(url)
        .then(function(response) {
            console.log(response);
        })
        .catch(function(error) {
            console.error(error);
        });
}

export { delete_record, delete_records };