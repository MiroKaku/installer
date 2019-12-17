#ifndef MINNO_VERSION_H_AA7B48FE_D585_49F7_B269_F3D1F2918DFD
#define MINNO_VERSION_H_AA7B48FE_D585_49F7_B269_F3D1F2918DFD

#define MINNO_VERSION_MAJOR         1
#define MINNO_VERSION_MINOR         0
#define MINNO_VERSION_PATCH         0
#define MINNO_VERSION_BUILD         0

#define MINNO_APP_ID_32_STR         "{72661C06-DB84-4FF8-9D12-AAE30F67AADC}"
#define MINNO_APP_ID_64_STR         "{8EAAE114-31DD-440A-A985-664728DB8751}"
#define MINNO_APP_MUTEX_32_STR      MINNO_APP_ID_32_STR
#define MINNO_APP_MUTEX_64_STR      MINNO_APP_ID_64_STR
#define MINNO_APP_NAME_STR          "My Program"
#define MINNO_EXE_NAME_STR          "Program.exe"
#define MINNO_APP_FRIENDLY_NAME_STR "My Program"
#define MINNO_COMPANY_NAME_STR      "example"
#define MINNO_COMPANY_URL_STR       "http://www.example.com/"
#define MINNO_SUPPORT_URL_STR       MINNO_COMPANY_URL_STR
#define MINNO_UPDATE_URL_STR        MINNO_COMPANY_URL_STR
#define MINNO_CONTACT_STR           MINNO_COMPANY_NAME_STR
#define MINNO_README_URL_STR        "https://github.com/MiroKaku/installer/blob/master/README.md"
#define MINNO_LICENSE_URL_STR       "https://github.com/MiroKaku/installer/blob/master/LICENSE"
#define MINNO_LICENSE_FILE_STR      "license"
#define MINNO_COPYRIGHT_STR         "Unlicense"

#ifdef _WIN64
    #define MINNO_APP_ID_STR        MINNO_APP_ID_64_STR
    #define MINNO_APP_MUTEX_STR     MINNO_APP_MUTEX_64_STR
#else
    #define MINNO_APP_ID_STR        MINNO_APP_ID_32_STR
    #define MINNO_APP_MUTEX_STR     MINNO_APP_MUTEX_32_STR
#endif

#endif
