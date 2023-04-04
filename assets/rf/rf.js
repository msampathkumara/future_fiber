// error handling

var errorMo = false;
var errorOperation = false;

// 1 error
if (document.querySelector('article.validationerror h3')) {
    const elements = [...document.querySelectorAll('article.validationerror h3')].filter(el => el.textContent.includes('Invalid user ID'));
    if (elements.length > 0) {
        // console.log(document.querySelector(".module.active #txt[type='text']"));
        // document.querySelector(".module.active #txt[type='text']").value = "ccccccccccc";
        onError.postMessage('userName');
    }
}
//2
if (document.querySelector('article.validationerror h3')) {
    const elements = [...document.querySelectorAll('article.validationerror h3')].filter(el => el.textContent.includes('Wrong password'));
    if (elements.length > 0) {
        // console.log(document.querySelector(".module.active #txt[type='password']"));
        // document.querySelector(".module.active #txt[type='password']").value = "xx";
        onError.postMessage('password');
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


// 1
if (document.querySelector(".module.active [id='l_lbl@SYS4517_DT1']")) {
    document.querySelector(".module.active #txt[type='text']").value = "@@user";
//    document.getElementById("Form1").submit();
}

// 2
else if (document.querySelector(".module.active [id='l_lbl@SYS30019_DT1']")) {
    document.querySelector(".module.active #txt[type='password']").value = "@@pass";
//    document.getElementById("Form1").submit();
}

// 3
else if (document.querySelector("#NorthSailsReportAsFinished04_NorthSails01")) {
    document.querySelector("#NorthSailsReportAsFinished04_NorthSails01").click();
}
// 4 Production order
else if (document.querySelector(".module.active [id='l_lbl@SYS89639_DT1']")) {
    if (!errorMo) {
        document.querySelector(".module.active #txt[type='text']").value = "@@mo";
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
    if (!errorOperation) document.querySelector(".module.active #txt[type='text']").value = "@@min";
}
// 9 To Oper. No.
else if (document.querySelector(".module.active [id='l_lbl@SYS22378_DT1']")) {
    if (!errorOperation) document.querySelector(".module.active #txt[type='text']").value = "@@max";
}
// 10 Location
else if (document.querySelector(".module.active [id='l_lbl@SYS3794_DT1']")) {
    setTimeout(function () {
        document.getElementById("Form1").submit();
    }, 1000)
}
// 11 Quantity of labels
//else if (document.querySelector(".module.active [id='l_lbl@SYS56421_DT1']")) {
//    document.querySelector(".module.active #txt[type='text']").value = "10";
//}

setTimeout(function () {
    try {
        onSuccess.postMessage(document.getElementsByClassName('success').length > 0)
    } catch (e) {

    }
}, 1000);



