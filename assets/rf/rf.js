function submitForm() {
    setTimeout(function () {
        document.getElementById("Form1").submit();
    }, 1000)
}


// error handling

var errorMo = false;
var errorOperation = false;
var errorCred = false;
var isStarted = @@started;



// 1 error
if (document.querySelector('article.validationerror h3')) {
    const elements = [...document.querySelectorAll('article.validationerror h3')].filter(el => el.textContent.includes('Invalid user ID'));
    if (elements.length > 0) {
        onError.postMessage('userName');
        errorCred = true;
    }
}
//2
if (document.querySelector('article.validationerror h3')) {
    const elements = [...document.querySelectorAll('article.validationerror h3')].filter(el => el.textContent.includes('Wrong password'));
    if (elements.length > 0) {
        onError.postMessage('password');
        errorCred = true;
    }
}

if (document.querySelector('article.validationerror h3')) {
    const elements = [...document.querySelectorAll('article.validationerror h3')].filter(el => el.textContent.includes('Invalid order number'));
    if (elements.length > 0) {
        errorMo = true;
    }
}

if (document.querySelector('article.validationerror h3')) {
    const elements = [...document.querySelectorAll('article.validationerror h3')].filter(el => el.textContent.includes('Invalid operation'));
    if (elements.length > 0) {
        errorOperation = true;
    }
}



//if(isStarted==false ){
// setTimeout(function () {
//        try {
//            onStart.postMessage(true);
//        } catch (e) {
//        }
//    }, 1000);
// document.querySelector("#Key").value = 114;
// submitForm();
//}

// 1
if (document.querySelector(".module.active [id='l_lbl@SYS4517_DT1']")) {
    document.querySelector(".module.active #txt[type='text']").value = "@@user";
    if (!errorCred) {
        submitForm();
    }
}



// 2
else if (document.querySelector(".module.active [id='l_lbl@SYS30019_DT1']")) {
    document.querySelector(".module.active #txt[type='password']").value = "@@pass";
    if (!errorCred) {
        submitForm();
    }
}

// 3
else if (document.querySelector("#NorthSailsReportAsFinished04_NorthSails01")) {
    document.querySelector("#NorthSailsReportAsFinished04_NorthSails01").click();
}
// 4 Production order
else if (document.querySelector(".module.active [id='l_lbl@SYS89639_DT1']")) {
    if (!errorMo) {
        document.querySelector(".module.active #txt[type='text']").value = "@@mo";
        submitForm();
    }
}
// 5 Good quantity
// else if (document.querySelector(".module.active [id='l_lbl@SYS4638_DT1']")) {
//     document.querySelector(".module.active #txt[type='text']").value = "MOSL-00027403";
// }
// 6 Error quantity
// else if (document.querySelector(".module.active [id='l_lbl@SYS2083_DT1']")) {
//     document.querySelector(".module.active #txt[type='text']").value = "MOSL-00027403";
// }
// 7 From Oper. No.
// else if (document.querySelector(".module.active [id='l_lbl@SYS22377_DT1']")) {
//     document.querySelector(".module.active #txt[type='text']").value = "10";
// }
// 8 From Oper. No.
else if (document.querySelector(".module.active [id='l_lbl@SYS22377_DT1']")) {
    if (!errorOperation) {
        document.querySelector(".module.active #txt[type='text']").value = "@@min";
        submitForm();
    }
}
// 9 To Oper. No.
else if (document.querySelector(".module.active [id='l_lbl@SYS22378_DT1']")) {
    if (!errorOperation) {
        document.querySelector(".module.active #txt[type='text']").value = "@@max";
        submitForm();
    }
}
// 10 Location
else if (document.querySelector(".module.active [id='l_lbl@SYS3794_DT1']")) {
    submitForm();
}
//// 11 Quantity of labels
//else if (document.querySelector(".module.active [id='l_lbl@SYS56421_DT1']")) {
//    document.querySelector(".module.active #txt[type='text']").value = "10";
//}

// 11 Quantity of labels
else if (document.querySelector(".success.mini")) {
    setTimeout(function () {
        try {
            onSuccess.postMessage(document.getElementsByClassName('success').length > 0)
        } catch (e) {
        }
    }, 1000);
}







