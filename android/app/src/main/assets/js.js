(function () {
        if (document.getElementsByClassName("validationerror").length>0) {
            return;
        }if (document.getElementsByClassName("success").length>0) {
            java.showFinishButton();
            return;
        }
        if (document.getElementById('txtUser')) {
            if (document.getElementsByClassName("validationerror").length > 0) {
                java.showUsernameInput();
                return;
            }
            document.getElementById('txtUser').value = '@@user';
            document.getElementById('Form1').submit();
        }
        if (document.getElementById('txtPass')) {
            if (document.getElementsByClassName("validationerror").length > 0) {
                java.showUsernameInput();
                return;
            }
            document.getElementById('txtPass').value = '@@pass';
            setTimeout(function () {
                document.getElementById('Form1').submit();
            }, 1000);

            return;
        }
        if (document.getElementById('SL Production')) {
            setTimeout(function () {
                document.getElementById('SL Production').click();
            }, 1000);
        }

        if (document.getElementById('NorthSailsReportAsFinished02_SL')) {

            document.getElementById('NorthSailsReportAsFinished02_SL').click();

        }
        if (document.getElementById('l_lbl7@SYS3794_DT1')) {


            return;
        }
        if (document.getElementById('l_lbl5@SYS75853_DT1')) {
            if (@@low == 0) {
                return;
            }
            document.getElementById('txt').value = "@@low";
            document.getElementById('Form1').submit();

        }
        if (document.getElementById('l_lbl4@SYS75853_DT1')) {
            if (@@max == 0) {
                return;
            }
            document.getElementById('txt').value = "@@max";
            document.getElementById('Form1').submit();

        } else if (document.getElementById('l_lbl2@SYS89639_DT1')) {
            document.getElementById('txt').value = "@@mo";
            document.getElementById('Form1').submit();

        }


    }
)();

