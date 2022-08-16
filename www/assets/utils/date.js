
let date_input = document.querySelector("input[type='date']");
let next_date_button = document.getElementsByClassName("next-date-button")[0];
let previous_date_button = document.getElementsByClassName("previous-date-button")[0];

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
    date_link.href = `/today/${date.toISOString().split('T')[0]}/species`;
}

next_date_button.addEventListener("click", next_date);
previous_date_button.addEventListener("click", previous_date);