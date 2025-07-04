namespace APIInvoice;

permissionset 90000 APIInvoice
{
    Assignable = true;
    Permissions = tabledata "NDC-API Customer Bills"=RIMD,
        tabledata "NDC-API Global Setup"=RIMD,
        tabledata "NDC-Branch Api Mapping"=RIMD,
        tabledata "NDC-Invoice Detail"=RIMD,
        tabledata "NDC-Payment Term"=RIMD,
        tabledata "NDC-PaymentCode Api Mapping"=RIMD,
        tabledata "NDC-Transaction DateTime"=RIMD,
        table "NDC-API Customer Bills"=X,
        table "NDC-API Global Setup"=X,
        table "NDC-Branch Api Mapping"=X,
        table "NDC-Invoice Detail"=X,
        table "NDC-Payment Term"=X,
        table "NDC-PaymentCode Api Mapping"=X,
        table "NDC-Transaction DateTime"=X,
        codeunit "NDC-GenerateInvoiceAPI"=X,
        page "NDC-Ad Payment API"=X,
        page "NDC-AdInvDetail"=X,
        page "NDC-Admin Bill Transection"=X,
        page "NDC-API Global Setup"=X,
        page "NDC-BillHeader"=X,
        page "NDC-Branch Mapping"=X,
        page "NDC-customerbillapi"=X,
        page "NDC-InvoiceDetailApi"=X,
        page "NDC-Payment Mapping"=X,
        page "NDC-Payment Term API"=X,
        page "NDC-Transection DateTime API"=X;
}