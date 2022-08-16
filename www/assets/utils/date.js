let date_input;
let endpoint;

try {
    date_input = document.querySelector(".date-selector input[type='date']");
    let next_date_button = document.getElementsByClassName("next-date-button")[0];
    let previous_date_button = document.getElementsByClassName("previous-date-button")[0];
    endpoint = document.querySelector(".date-selector a").href.split("/")[3];

    next_date_button.addEventListener("click", next_date);
    previous_date_button.addEventListener("click", previous_date);
} catch {
    console.debug("no date input found");
}

function next_date() {
    let date = new Date(date_input.value);
    date.setDate(date.getDate() + 1);
    date_input.value = date.toISOString().split('T')[0];
    update_date_link();
}

function previous_date() {
    let date = new Date(date_input.value);
    date.setDate(date.getDate() - 1);
    date_input.value = date.toISOString().split('T')[0];
    update_date_link();
}

function update_date_link() {
    let date = new Date(date_input.value);
    let date_link = document.querySelector(".date-selector a");
    date_link.href = `/${endpoint}/${date.toISOString().split('T')[0]}/`;
}
