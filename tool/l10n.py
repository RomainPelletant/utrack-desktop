#!/usr/bin/env python3
"""Single source of truth for UTD translations.

Generates:
  - lib/l10n/app_<locale>.arb          (Flutter UI, compiled by `flutter gen-l10n`)
  - macos/Runner/<lang>.lproj/Localizable.strings  (native macOS menus)

Usage: python3 tool/l10n.py   (then `flutter gen-l10n` or any flutter build)
To add a string, add its key to FLUTTER_KEYS or NATIVE_KEYS and a translation
to every language below, then re-run the script.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

FLUTTER_KEYS = [
    "serverTitle",
    "serverPrompt",
    "serverUrlLabel",
    "connect",
    "cancel",
    "invalidUrl",
    "serverUnreachable",
    "retry",
    "changeServer",
]

# %@ is the application name.
NATIVE_KEYS = [
    "menu.about",
    "menu.changeServer",
    "menu.services",
    "menu.hide",
    "menu.hideOthers",
    "menu.showAll",
    "menu.quit",
    "menu.edit",
    "menu.undo",
    "menu.redo",
    "menu.cut",
    "menu.copy",
    "menu.paste",
    "menu.pasteAndMatchStyle",
    "menu.delete",
    "menu.selectAll",
    "menu.view",
    "menu.enterFullScreen",
    "menu.navigation",
    "menu.back",
    "menu.forward",
    "menu.reload",
    "menu.window",
    "menu.minimize",
    "menu.zoom",
    "menu.bringAllToFront",
    "menu.help",
]

# (Flutter ARB locale, macOS .lproj name)
LANGUAGES = {
    "en": ("en", "en"),
    "fr": ("fr", "fr"),
    "de": ("de", "de"),
    "es": ("es", "es"),
    "it": ("it", "it"),
    "pt-BR": ("pt", "pt-BR"),
    "pt-PT": ("pt_PT", "pt-PT"),
    "nl": ("nl", "nl"),
    "sv": ("sv", "sv"),
    "da": ("da", "da"),
    "nb": ("nb", "nb"),
    "fi": ("fi", "fi"),
    "pl": ("pl", "pl"),
    "cs": ("cs", "cs"),
    "sk": ("sk", "sk"),
    "hu": ("hu", "hu"),
    "ro": ("ro", "ro"),
    "hr": ("hr", "hr"),
    "bg": ("bg", "bg"),
    "el": ("el", "el"),
    "tr": ("tr", "tr"),
    "ru": ("ru", "ru"),
    "uk": ("uk", "uk"),
    "ar": ("ar", "ar"),
    "he": ("he", "he"),
    "hi": ("hi", "hi"),
    "th": ("th", "th"),
    "vi": ("vi", "vi"),
    "id": ("id", "id"),
    "ms": ("ms", "ms"),
    "ja": ("ja", "ja"),
    "ko": ("ko", "ko"),
    "zh-Hans": ("zh", "zh-Hans"),
    "zh-Hant": ("zh_Hant", "zh-Hant"),
    "ca": ("ca", "ca"),
}

FLUTTER = {
    "en": ["YouTrack server", "Enter the address of your YouTrack instance.", "Server address", "Connect", "Cancel", "Invalid address", "Unable to reach the server", "Retry", "Change server"],
    "fr": ["Serveur YouTrack", "Saisissez l'adresse de votre instance YouTrack.", "Adresse du serveur", "Se connecter", "Annuler", "Adresse invalide", "Impossible de joindre le serveur", "Réessayer", "Changer de serveur"],
    "de": ["YouTrack-Server", "Geben Sie die Adresse Ihrer YouTrack-Instanz ein.", "Serveradresse", "Verbinden", "Abbrechen", "Ungültige Adresse", "Server nicht erreichbar", "Erneut versuchen", "Server wechseln"],
    "es": ["Servidor de YouTrack", "Introduce la dirección de tu instancia de YouTrack.", "Dirección del servidor", "Conectar", "Cancelar", "Dirección no válida", "No se puede acceder al servidor", "Reintentar", "Cambiar de servidor"],
    "it": ["Server YouTrack", "Inserisci l'indirizzo della tua istanza YouTrack.", "Indirizzo del server", "Connetti", "Annulla", "Indirizzo non valido", "Impossibile raggiungere il server", "Riprova", "Cambia server"],
    "pt-BR": ["Servidor do YouTrack", "Digite o endereço da sua instância do YouTrack.", "Endereço do servidor", "Conectar", "Cancelar", "Endereço inválido", "Não foi possível acessar o servidor", "Tentar novamente", "Mudar de servidor"],
    "pt-PT": ["Servidor YouTrack", "Introduza o endereço da sua instância YouTrack.", "Endereço do servidor", "Ligar", "Cancelar", "Endereço inválido", "Não é possível contactar o servidor", "Tentar novamente", "Mudar de servidor"],
    "nl": ["YouTrack-server", "Voer het adres van je YouTrack-instantie in.", "Serveradres", "Verbinden", "Annuleren", "Ongeldig adres", "Kan de server niet bereiken", "Opnieuw proberen", "Wijzig server"],
    "sv": ["YouTrack-server", "Ange adressen till din YouTrack-instans.", "Serveradress", "Anslut", "Avbryt", "Ogiltig adress", "Det går inte att nå servern", "Försök igen", "Byt server"],
    "da": ["YouTrack-server", "Angiv adressen på din YouTrack-instans.", "Serveradresse", "Opret forbindelse", "Annuller", "Ugyldig adresse", "Serveren kan ikke nås", "Prøv igen", "Skift server"],
    "nb": ["YouTrack-server", "Skriv inn adressen til YouTrack-instansen din.", "Serveradresse", "Koble til", "Avbryt", "Ugyldig adresse", "Får ikke kontakt med serveren", "Prøv igjen", "Bytt server"],
    "fi": ["YouTrack-palvelin", "Anna YouTrack-instanssisi osoite.", "Palvelimen osoite", "Yhdistä", "Peruuta", "Virheellinen osoite", "Palvelimeen ei saada yhteyttä", "Yritä uudelleen", "Vaihda palvelin"],
    "pl": ["Serwer YouTrack", "Wpisz adres swojej instancji YouTrack.", "Adres serwera", "Połącz", "Anuluj", "Nieprawidłowy adres", "Nie można połączyć się z serwerem", "Spróbuj ponownie", "Zmień serwer"],
    "cs": ["Server YouTrack", "Zadejte adresu své instance YouTrack.", "Adresa serveru", "Připojit", "Zrušit", "Neplatná adresa", "Server je nedostupný", "Zkusit znovu", "Změnit server"],
    "sk": ["Server YouTrack", "Zadajte adresu svojej inštancie YouTrack.", "Adresa servera", "Pripojiť", "Zrušiť", "Neplatná adresa", "Server je nedostupný", "Skúsiť znova", "Zmeniť server"],
    "hu": ["YouTrack-szerver", "Adja meg a YouTrack-példány címét.", "Szervercím", "Csatlakozás", "Mégse", "Érvénytelen cím", "A szerver nem érhető el", "Újra", "Szerver módosítása"],
    "ro": ["Server YouTrack", "Introduceți adresa instanței YouTrack.", "Adresa serverului", "Conectare", "Anulați", "Adresă nevalidă", "Serverul nu poate fi accesat", "Reîncercați", "Schimbați serverul"],
    "hr": ["YouTrack poslužitelj", "Unesite adresu svoje YouTrack instance.", "Adresa poslužitelja", "Poveži se", "Odustani", "Nevažeća adresa", "Poslužitelj nije dostupan", "Pokušaj ponovno", "Promijeni poslužitelj"],
    "bg": ["Сървър на YouTrack", "Въведете адреса на вашата инстанция на YouTrack.", "Адрес на сървъра", "Свързване", "Отказ", "Невалиден адрес", "Сървърът е недостъпен", "Опитай отново", "Смяна на сървъра"],
    "el": ["Διακομιστής YouTrack", "Εισαγάγετε τη διεύθυνση της εγκατάστασης YouTrack.", "Διεύθυνση διακομιστή", "Σύνδεση", "Ακύρωση", "Μη έγκυρη διεύθυνση", "Δεν είναι δυνατή η σύνδεση με τον διακομιστή", "Επανάληψη", "Αλλαγή διακομιστή"],
    "tr": ["YouTrack sunucusu", "YouTrack örneğinizin adresini girin.", "Sunucu adresi", "Bağlan", "İptal", "Geçersiz adres", "Sunucuya ulaşılamıyor", "Yeniden dene", "Sunucuyu değiştir"],
    "ru": ["Сервер YouTrack", "Введите адрес вашего экземпляра YouTrack.", "Адрес сервера", "Подключиться", "Отмена", "Недопустимый адрес", "Не удаётся подключиться к серверу", "Повторить", "Сменить сервер"],
    "uk": ["Сервер YouTrack", "Введіть адресу вашого екземпляра YouTrack.", "Адреса сервера", "Підключитися", "Скасувати", "Неприпустима адреса", "Не вдається зʼєднатися із сервером", "Повторити", "Змінити сервер"],
    "ar": ["خادم YouTrack", "أدخل عنوان مثيل YouTrack الخاص بك.", "عنوان الخادم", "اتصال", "إلغاء", "عنوان غير صالح", "تعذر الوصول إلى الخادم", "إعادة المحاولة", "تغيير الخادم"],
    "he": ["שרת YouTrack", "הזינו את הכתובת של מופע ה-YouTrack שלכם.", "כתובת השרת", "התחברות", "ביטול", "כתובת לא חוקית", "לא ניתן להתחבר לשרת", "ניסיון חוזר", "החלפת שרת"],
    "hi": ["YouTrack सर्वर", "अपने YouTrack इंस्टेंस का पता दर्ज करें।", "सर्वर का पता", "कनेक्ट करें", "रद्द करें", "अमान्य पता", "सर्वर तक नहीं पहुँचा जा सका", "फिर से कोशिश करें", "सर्वर बदलें"],
    "th": ["เซิร์ฟเวอร์ YouTrack", "ป้อนที่อยู่ของอินสแตนซ์ YouTrack ของคุณ", "ที่อยู่เซิร์ฟเวอร์", "เชื่อมต่อ", "ยกเลิก", "ที่อยู่ไม่ถูกต้อง", "ไม่สามารถเข้าถึงเซิร์ฟเวอร์ได้", "ลองอีกครั้ง", "เปลี่ยนเซิร์ฟเวอร์"],
    "vi": ["Máy chủ YouTrack", "Nhập địa chỉ phiên bản YouTrack của bạn.", "Địa chỉ máy chủ", "Kết nối", "Hủy", "Địa chỉ không hợp lệ", "Không thể kết nối tới máy chủ", "Thử lại", "Đổi máy chủ"],
    "id": ["Server YouTrack", "Masukkan alamat instans YouTrack Anda.", "Alamat server", "Hubungkan", "Batal", "Alamat tidak valid", "Server tidak dapat dijangkau", "Coba lagi", "Ganti server"],
    "ms": ["Pelayan YouTrack", "Masukkan alamat tika YouTrack anda.", "Alamat pelayan", "Sambung", "Batal", "Alamat tidak sah", "Pelayan tidak dapat dicapai", "Cuba lagi", "Tukar pelayan"],
    "ja": ["YouTrackサーバ", "YouTrackインスタンスのアドレスを入力してください。", "サーバのアドレス", "接続", "キャンセル", "無効なアドレス", "サーバに接続できません", "再試行", "サーバを変更"],
    "ko": ["YouTrack 서버", "YouTrack 인스턴스의 주소를 입력하십시오.", "서버 주소", "연결", "취소", "유효하지 않은 주소", "서버에 연결할 수 없음", "다시 시도", "서버 변경"],
    "zh-Hans": ["YouTrack 服务器", "请输入您的 YouTrack 实例地址。", "服务器地址", "连接", "取消", "地址无效", "无法连接到服务器", "重试", "更改服务器"],
    "zh-Hant": ["YouTrack 伺服器", "請輸入你的 YouTrack 實例位址。", "伺服器位址", "連線", "取消", "位址無效", "無法連線至伺服器", "重試", "更改伺服器"],
    "ca": ["Servidor de YouTrack", "Introdueix l'adreça de la teva instància de YouTrack.", "Adreça del servidor", "Connecta", "Cancel·la", "Adreça no vàlida", "No es pot accedir al servidor", "Torna-ho a provar", "Canvia de servidor"],
}

NATIVE = {
    "en": ["About %@", "Change Server…", "Services", "Hide %@", "Hide Others", "Show All", "Quit %@", "Edit", "Undo", "Redo", "Cut", "Copy", "Paste", "Paste and Match Style", "Delete", "Select All", "View", "Enter Full Screen", "Navigation", "Back", "Forward", "Reload", "Window", "Minimize", "Zoom", "Bring All to Front", "Help"],
    "fr": ["À propos de %@", "Changer de serveur…", "Services", "Masquer %@", "Masquer les autres", "Tout afficher", "Quitter %@", "Édition", "Annuler", "Rétablir", "Couper", "Copier", "Coller", "Coller et adapter le style", "Supprimer", "Tout sélectionner", "Présentation", "Passer en mode plein écran", "Navigation", "Précédent", "Suivant", "Recharger", "Fenêtre", "Placer dans le Dock", "Réduire/agrandir", "Tout ramener au premier plan", "Aide"],
    "de": ["Über %@", "Server wechseln …", "Dienste", "%@ ausblenden", "Andere ausblenden", "Alle einblenden", "%@ beenden", "Bearbeiten", "Widerrufen", "Wiederholen", "Ausschneiden", "Kopieren", "Einsetzen", "Einsetzen und Stil anpassen", "Löschen", "Alles auswählen", "Darstellung", "Vollbildmodus aktivieren", "Navigation", "Zurück", "Vorwärts", "Neu laden", "Fenster", "Im Dock ablegen", "Zoomen", "Alle nach vorne bringen", "Hilfe"],
    "es": ["Acerca de %@", "Cambiar de servidor…", "Servicios", "Ocultar %@", "Ocultar otros", "Mostrar todo", "Salir de %@", "Edición", "Deshacer", "Rehacer", "Cortar", "Copiar", "Pegar", "Pegar y mantener estilo", "Eliminar", "Seleccionar todo", "Visualización", "Pasar a pantalla completa", "Navegación", "Atrás", "Adelante", "Volver a cargar", "Ventana", "Minimizar", "Zoom", "Traer todo al frente", "Ayuda"],
    "it": ["Informazioni su %@", "Cambia server…", "Servizi", "Nascondi %@", "Nascondi altre", "Mostra tutte", "Esci da %@", "Composizione", "Annulla", "Ripeti", "Taglia", "Copia", "Incolla", "Incolla e mantieni lo stile", "Elimina", "Seleziona tutto", "Vista", "Attiva modalità a tutto schermo", "Navigazione", "Indietro", "Avanti", "Ricarica", "Finestra", "Contrai", "Ridimensiona", "Porta tutto in primo piano", "Aiuto"],
    "pt-BR": ["Sobre o %@", "Mudar de Servidor…", "Serviços", "Ocultar %@", "Ocultar Outros", "Mostrar Tudo", "Encerrar %@", "Editar", "Desfazer", "Refazer", "Recortar", "Copiar", "Colar", "Colar e Manter Estilo", "Apagar", "Selecionar Tudo", "Visualizar", "Usar Tela Cheia", "Navegação", "Voltar", "Avançar", "Recarregar", "Janela", "Minimizar", "Zoom", "Trazer Todas para a Frente", "Ajuda"],
    "pt-PT": ["Acerca do %@", "Mudar de servidor…", "Serviços", "Ocultar %@", "Ocultar outros", "Mostrar tudo", "Sair do %@", "Edição", "Desfazer", "Refazer", "Cortar", "Copiar", "Colar", "Colar e manter estilo", "Apagar", "Selecionar tudo", "Visualização", "Entrar em ecrã completo", "Navegação", "Anterior", "Seguinte", "Recarregar", "Janela", "Minimizar", "Zoom", "Passar tudo para a frente", "Ajuda"],
    "nl": ["Over %@", "Wijzig server…", "Voorzieningen", "Verberg %@", "Verberg andere", "Toon alles", "Stop %@", "Wijzig", "Herstel", "Opnieuw", "Knip", "Kopieer", "Plak", "Plak en behoud stijl", "Verwijder", "Selecteer alles", "Weergave", "Activeer schermvullende weergave", "Navigatie", "Terug", "Vooruit", "Herlaad", "Venster", "Minimaliseer", "Zoom", "Alles op voorgrond", "Help"],
    "sv": ["Om %@", "Byt server…", "Tjänster", "Göm %@", "Göm övriga", "Visa alla", "Avsluta %@", "Redigera", "Ångra", "Gör om", "Klipp ut", "Kopiera", "Klistra in", "Klistra in och matcha stil", "Radera", "Markera alla", "Innehåll", "Använd helskärm", "Navigering", "Bakåt", "Framåt", "Läs in igen", "Fönster", "Minimera", "Zooma", "Lägg alla överst", "Hjälp"],
    "da": ["Om %@", "Skift server…", "Tjenester", "Skjul %@", "Skjul andre", "Vis alle", "Slut %@", "Rediger", "Fortryd", "Annuller fortryd", "Klip", "Kopier", "Indsæt", "Indsæt og tilpas stil", "Slet", "Vælg alt", "Oversigt", "Vis på fuld skærm", "Navigation", "Tilbage", "Frem", "Genindlæs", "Vindue", "Minimer", "Zoom", "Anbring alle forrest", "Hjælp"],
    "nb": ["Om %@", "Bytt server…", "Tjenester", "Skjul %@", "Skjul andre", "Vis alle", "Avslutt %@", "Rediger", "Angre", "Gjør om", "Klipp ut", "Kopier", "Lim inn", "Lim inn og bruk samme stil", "Slett", "Marker alt", "Vis", "Bruk fullskjerm", "Navigering", "Tilbake", "Frem", "Last inn på nytt", "Vindu", "Minimer", "Zoom", "Legg alle fremst", "Hjelp"],
    "fi": ["Tietoja: %@", "Vaihda palvelin…", "Palvelut", "Kätke %@", "Kätke muut", "Näytä kaikki", "Lopeta %@", "Muokkaa", "Kumoa", "Tee uudelleen", "Leikkaa", "Kopioi", "Sijoita", "Sijoita ja sovita tyyli", "Poista", "Valitse kaikki", "Näytä", "Siirry koko näytön tilaan", "Navigointi", "Edellinen", "Seuraava", "Lataa uudelleen", "Ikkuna", "Pienennä", "Zoomaa", "Tuo kaikki eteen", "Ohjeet"],
    "pl": ["O programie %@", "Zmień serwer…", "Usługi", "Ukryj %@", "Ukryj pozostałe", "Pokaż wszystkie", "Zakończ %@", "Edycja", "Cofnij", "Przywróć", "Wytnij", "Kopiuj", "Wklej", "Wklej i dopasuj styl", "Usuń", "Zaznacz wszystko", "Widok", "Włącz tryb pełnoekranowy", "Nawigacja", "Wstecz", "Dalej", "Odśwież", "Okno", "Minimalizuj", "Powiększ", "Przenieś wszystko na wierzch", "Pomoc"],
    "cs": ["O aplikaci %@", "Změnit server…", "Služby", "Skrýt %@", "Skrýt ostatní", "Zobrazit vše", "Ukončit %@", "Úpravy", "Odvolat", "Znovu", "Vyjmout", "Kopírovat", "Vložit", "Vložit a přizpůsobit styl", "Smazat", "Vybrat vše", "Zobrazení", "Zapnout režim celé obrazovky", "Navigace", "Zpět", "Vpřed", "Načíst znovu", "Okno", "Minimalizovat", "Zvětšit/zmenšit", "Převést vše do popředí", "Nápověda"],
    "sk": ["O aplikácii %@", "Zmeniť server…", "Služby", "Skryť %@", "Skryť ostatné", "Zobraziť všetko", "Ukončiť %@", "Upraviť", "Odvolať", "Znova", "Vystrihnúť", "Kopírovať", "Vložiť", "Vložiť a prispôsobiť štýl", "Vymazať", "Vybrať všetko", "Zobraziť", "Zapnúť režim celej obrazovky", "Navigácia", "Späť", "Dopredu", "Znova načítať", "Okno", "Minimalizovať", "Zväčšiť", "Preniesť všetko dopredu", "Pomoc"],
    "hu": ["A(z) %@ névjegye", "Szerver módosítása…", "Szolgáltatások", "%@ elrejtése", "Egyebek elrejtése", "Az összes megjelenítése", "Kilépés: %@", "Szerkesztés", "Visszavonás", "Ismétlés", "Kivágás", "Másolás", "Beillesztés", "Beillesztés stílusegyeztetéssel", "Törlés", "Az összes kijelölése", "Nézet", "Belépés a teljes képernyős módba", "Navigáció", "Vissza", "Előre", "Újratöltés", "Ablak", "Kis méret", "Nagyítás", "Az összes előtérbe hozása", "Súgó"],
    "ro": ["Despre %@", "Schimbă serverul…", "Servicii", "Ascunde %@", "Ascunde celelalte", "Afișează-le pe toate", "Ieși din %@", "Editare", "Anulează", "Refă", "Taie", "Copiază", "Lipește", "Lipește și potrivește stilul", "Șterge", "Selectează tot", "Afișare", "Intră pe ecran complet", "Navigare", "Înapoi", "Înainte", "Reîncarcă", "Fereastră", "Minimizează", "Zoom", "Adu-le pe toate în față", "Ajutor"],
    "hr": ["O aplikaciji %@", "Promijeni poslužitelj…", "Usluge", "Sakrij %@", "Sakrij ostale", "Prikaži sve", "Zatvori %@", "Uredi", "Poništi", "Ponovi", "Izreži", "Kopiraj", "Zalijepi", "Zalijepi i uskladi stil", "Obriši", "Odaberi sve", "Prikaz", "Uđi u prikaz preko cijelog zaslona", "Navigacija", "Natrag", "Naprijed", "Ponovno učitaj", "Prozor", "Minimiziraj", "Zumiraj", "Postavi sve naprijed", "Pomoć"],
    "bg": ["За %@", "Смяна на сървъра…", "Услуги", "Скрий %@", "Скрий другите", "Покажи всички", "Изход от %@", "Редакция", "Отмени", "Повтори", "Изрежи", "Копирай", "Постави", "Постави и съгласувай стила", "Изтрий", "Избери всичко", "Изглед", "Цял екран", "Навигация", "Назад", "Напред", "Презареди", "Прозорец", "Минимизирай", "Мащабирай", "Изведи всички отпред", "Помощ"],
    "el": ["Σχετικά με το %@", "Αλλαγή διακομιστή…", "Υπηρεσίες", "Απόκρυψη %@", "Απόκρυψη άλλων", "Εμφάνιση όλων", "Τερματισμός %@", "Επεξεργασία", "Αναίρεση", "Ακύρωση αναίρεσης", "Αποκοπή", "Αντιγραφή", "Επικόλληση", "Επικόλληση και αντιστοίχιση στιλ", "Διαγραφή", "Επιλογή όλων", "Προβολή", "Είσοδος σε πλήρη οθόνη", "Πλοήγηση", "Πίσω", "Εμπρός", "Επαναφόρτωση", "Παράθυρο", "Ελαχιστοποίηση", "Ζουμ", "Μεταφορά όλων μπροστά", "Βοήθεια"],
    "tr": ["%@ Hakkında", "Sunucuyu Değiştir…", "Servisler", "%@ Uygulamasını Gizle", "Diğerlerini Gizle", "Tümünü Göster", "%@ Uygulamasından Çık", "Düzen", "Geri Al", "Yinele", "Kes", "Kopyala", "Yapıştır", "Yapıştır ve Stili Eşleştir", "Sil", "Tümünü Seç", "Görüntü", "Tam Ekrana Gir", "Gezinti", "Geri", "İleri", "Yeniden Yükle", "Pencere", "Küçült", "Yakınlaştır", "Tümünü Öne Getir", "Yardım"],
    "ru": ["О программе %@", "Сменить сервер…", "Службы", "Скрыть %@", "Скрыть остальные", "Показать все", "Завершить %@", "Правка", "Отменить", "Повторить", "Вырезать", "Скопировать", "Вставить", "Вставить в том же стиле", "Удалить", "Выбрать все", "Вид", "Перейти в полноэкранный режим", "Навигация", "Назад", "Вперед", "Обновить", "Окно", "Свернуть", "Изменить масштаб", "Все окна — на передний план", "Справка"],
    "uk": ["Про %@", "Змінити сервер…", "Послуги", "Сховати %@", "Сховати інші", "Показати всі", "Вийти з %@", "Редагування", "Відмінити", "Повторити", "Вирізати", "Копіювати", "Вставити", "Вставити зі збереженням стилю", "Видалити", "Вибрати все", "Перегляд", "Увійти в повноекранний режим", "Навігація", "Назад", "Вперед", "Оновити", "Вікно", "Згорнути", "Масштаб", "Всі вікна наперед", "Довідка"],
    "ar": ["حول %@", "تغيير الخادم…", "الخدمات", "إخفاء %@", "إخفاء الآخرين", "إظهار الكل", "إنهاء %@", "تحرير", "تراجع", "إعادة", "قص", "نسخ", "لصق", "لصق ومطابقة النمط", "حذف", "تحديد الكل", "عرض", "الدخول إلى ملء الشاشة", "التنقل", "رجوع", "تقدم", "إعادة التحميل", "نافذة", "تصغير", "تكبير", "إحضار الكل إلى الأمام", "مساعدة"],
    "he": ["אודות %@", "החלפת שרת…", "שירותים", "הסתרת %@", "הסתרת האחרים", "הצגת הכל", "סיום %@", "עריכה", "ביטול פעולה", "ביצוע חוזר", "גזירה", "העתקה", "הדבקה", "הדבקה והתאמת סגנון", "מחיקה", "בחירת הכל", "תצוגה", "כניסה למסך מלא", "ניווט", "אחורה", "קדימה", "טעינה מחדש", "חלון", "מזעור", "הגדלה/הקטנה", "הבאת הכל לחזית", "עזרה"],
    "hi": ["%@ के बारे में", "सर्वर बदलें…", "सेवाएँ", "%@ छिपाएँ", "अन्य को छिपाएँ", "सभी दिखाएँ", "%@ से बाहर निकलें", "संपादित करें", "पहले जैसा करें", "फिर से करें", "काटें", "कॉपी करें", "पेस्ट करें", "पेस्ट करें और शैली मिलाएँ", "डिलीट करें", "सभी चुनें", "देखें", "फ़ुल स्क्रीन में जाएँ", "नेविगेशन", "पीछे", "आगे", "फिर से लोड करें", "विंडो", "छोटा करें", "ज़ूम करें", "सभी को सामने लाएँ", "सहायता"],
    "th": ["เกี่ยวกับ %@", "เปลี่ยนเซิร์ฟเวอร์…", "บริการ", "ซ่อน %@", "ซ่อนอื่นๆ", "แสดงทั้งหมด", "ออกจาก %@", "แก้ไข", "เลิกทำ", "ทำซ้ำ", "ตัด", "คัดลอก", "วาง", "วางและจับคู่ลักษณะ", "ลบ", "เลือกทั้งหมด", "มุมมอง", "เข้าสู่แบบเต็มหน้าจอ", "การนำทาง", "ย้อนกลับ", "ไปข้างหน้า", "โหลดซ้ำ", "หน้าต่าง", "ย่อ", "ซูม", "นำทั้งหมดมาด้านหน้า", "วิธีใช้"],
    "vi": ["Giới thiệu về %@", "Đổi máy chủ…", "Dịch vụ", "Ẩn %@", "Ẩn các ứng dụng khác", "Hiển thị tất cả", "Thoát %@", "Sửa", "Hoàn tác", "Làm lại", "Cắt", "Sao chép", "Dán", "Dán và khớp kiểu", "Xóa", "Chọn tất cả", "Xem", "Vào toàn màn hình", "Điều hướng", "Quay lại", "Tiến tới", "Tải lại", "Cửa sổ", "Thu nhỏ", "Thu/phóng", "Đưa tất cả ra trước", "Trợ giúp"],
    "id": ["Tentang %@", "Ganti Server…", "Layanan", "Sembunyikan %@", "Sembunyikan Lainnya", "Tampilkan Semua", "Keluar dari %@", "Edit", "Urungkan", "Ulangi", "Potong", "Salin", "Tempel", "Tempel dan Cocokkan Gaya", "Hapus", "Pilih Semua", "Tampilan", "Masuk ke Layar Penuh", "Navigasi", "Kembali", "Maju", "Muat Ulang", "Jendela", "Minimalkan", "Zoom", "Bawa Semua ke Depan", "Bantuan"],
    "ms": ["Mengenai %@", "Tukar Pelayan…", "Perkhidmatan", "Sembunyikan %@", "Sembunyikan Lain-lain", "Tunjukkan Semua", "Keluar %@", "Edit", "Buat Asal", "Buat Semula", "Potong", "Salin", "Tampal", "Tampal dan Padankan Gaya", "Padam", "Pilih Semua", "Paparan", "Masuk Skrin Penuh", "Navigasi", "Kembali", "Ke Hadapan", "Muat Semula", "Tetingkap", "Minimumkan", "Zum", "Bawa Semua ke Hadapan", "Bantuan"],
    "ja": ["%@について", "サーバを変更…", "サービス", "%@を非表示", "ほかを非表示", "すべてを表示", "%@を終了", "編集", "取り消す", "やり直す", "カット", "コピー", "ペースト", "ペーストしてスタイルを合わせる", "削除", "すべてを選択", "表示", "フルスクリーンにする", "移動", "戻る", "進む", "再読み込み", "ウインドウ", "しまう", "拡大/縮小", "すべてを手前に移動", "ヘルプ"],
    "ko": ["%@에 관하여", "서버 변경…", "서비스", "%@ 가리기", "기타 가리기", "모두 보기", "%@ 종료", "편집", "실행 취소", "실행 복귀", "오려두기", "복사하기", "붙여넣기", "붙여넣고 스타일 일치시키기", "삭제", "전체 선택", "보기", "전체 화면 시작", "탐색", "뒤로", "앞으로", "새로고침", "윈도우", "최소화", "확대/축소", "모두 앞으로 가져오기", "도움말"],
    "zh-Hans": ["关于%@", "更改服务器…", "服务", "隐藏%@", "隐藏其他", "全部显示", "退出%@", "编辑", "撤销", "重做", "剪切", "拷贝", "粘贴", "粘贴并匹配样式", "删除", "全选", "显示", "进入全屏幕", "导航", "后退", "前进", "重新载入", "窗口", "最小化", "缩放", "前置全部窗口", "帮助"],
    "zh-Hant": ["關於%@", "更改伺服器…", "服務", "隱藏%@", "隱藏其他", "顯示全部", "結束%@", "編輯", "還原", "重做", "剪下", "拷貝", "貼上", "貼上並符合樣式", "刪除", "全選", "顯示方式", "進入全螢幕", "導覽", "上一頁", "下一頁", "重新載入", "視窗", "縮到最小", "縮放", "將全部移至最前", "輔助說明"],
    "ca": ["Quant a %@", "Canvia de servidor…", "Serveis", "Amaga %@", "Amaga els altres", "Mostra-ho tot", "Surt de %@", "Edita", "Desfés", "Refés", "Retalla", "Copia", "Enganxa", "Enganxa i adapta l'estil", "Elimina", "Selecciona-ho tot", "Visualització", "Activa la pantalla completa", "Navegació", "Enrere", "Endavant", "Torna a carregar", "Finestra", "Minimitza", "Zoom", "Porta-ho tot al davant", "Ajuda"],
}


# Legal notices: (license, trademark, third-party licenses menu item).
# Shown in the native About panel; Flutter's license page gets "legalese"
# (license + trademark).
LEGAL_KEYS = ["about.license", "about.trademark", "menu.licenses"]

LEGAL = {
    "en": ("Distributed under the Apache License 2.0.", "YouTrack is a trademark of JetBrains s.r.o. UTD is an independent project, not affiliated with or endorsed by JetBrains.", "Third-Party Licenses…"),
    "fr": ("Distribué sous licence Apache 2.0.", "YouTrack est une marque de JetBrains s.r.o. UTD est un projet indépendant, ni affilié à JetBrains ni approuvé par JetBrains.", "Licences tierces…"),
    "de": ("Veröffentlicht unter der Apache-Lizenz 2.0.", "YouTrack ist eine Marke der JetBrains s.r.o. UTD ist ein unabhängiges Projekt, das weder mit JetBrains verbunden ist noch von JetBrains unterstützt wird.", "Lizenzen von Drittanbietern …"),
    "es": ("Distribuido bajo la licencia Apache 2.0.", "YouTrack es una marca comercial de JetBrains s.r.o. UTD es un proyecto independiente, no afiliado ni respaldado por JetBrains.", "Licencias de terceros…"),
    "it": ("Distribuito con licenza Apache 2.0.", "YouTrack è un marchio di JetBrains s.r.o. UTD è un progetto indipendente, non affiliato né approvato da JetBrains.", "Licenze di terze parti…"),
    "pt-BR": ("Distribuído sob a Licença Apache 2.0.", "YouTrack é uma marca comercial da JetBrains s.r.o. O UTD é um projeto independente, sem afiliação ou endosso da JetBrains.", "Licenças de Terceiros…"),
    "pt-PT": ("Distribuído ao abrigo da Licença Apache 2.0.", "YouTrack é uma marca comercial da JetBrains s.r.o. O UTD é um projeto independente, sem afiliação nem aprovação da JetBrains.", "Licenças de terceiros…"),
    "nl": ("Verspreid onder de Apache-licentie 2.0.", "YouTrack is een handelsmerk van JetBrains s.r.o. UTD is een onafhankelijk project dat niet gelieerd is aan of onderschreven wordt door JetBrains.", "Licenties van derden…"),
    "sv": ("Distribueras under Apache-licensen 2.0.", "YouTrack är ett varumärke som tillhör JetBrains s.r.o. UTD är ett oberoende projekt som inte är anknutet till eller godkänt av JetBrains.", "Tredjepartslicenser…"),
    "da": ("Distribueret under Apache-licensen 2.0.", "YouTrack er et varemærke tilhørende JetBrains s.r.o. UTD er et uafhængigt projekt, der ikke er tilknyttet eller godkendt af JetBrains.", "Tredjepartslicenser…"),
    "nb": ("Distribuert under Apache-lisensen 2.0.", "YouTrack er et varemerke som tilhører JetBrains s.r.o. UTD er et uavhengig prosjekt som ikke er tilknyttet eller godkjent av JetBrains.", "Tredjepartslisenser…"),
    "fi": ("Jaetaan Apache License 2.0 -lisenssillä.", "YouTrack on JetBrains s.r.o:n tavaramerkki. UTD on itsenäinen projekti, joka ei ole sidoksissa JetBrainsiin eikä JetBrainsin hyväksymä.", "Kolmansien osapuolten lisenssit…"),
    "pl": ("Rozpowszechniany na licencji Apache 2.0.", "YouTrack jest znakiem towarowym JetBrains s.r.o. UTD to niezależny projekt, niepowiązany z JetBrains ani przez nią niepopierany.", "Licencje innych firm…"),
    "cs": ("Šířeno pod licencí Apache 2.0.", "YouTrack je ochranná známka společnosti JetBrains s.r.o. UTD je nezávislý projekt, který není spojen se společností JetBrains ani jí schválen.", "Licence třetích stran…"),
    "sk": ("Šírené pod licenciou Apache 2.0.", "YouTrack je ochranná známka spoločnosti JetBrains s.r.o. UTD je nezávislý projekt, ktorý nie je prepojený so spoločnosťou JetBrains ani ňou schválený.", "Licencie tretích strán…"),
    "hu": ("Az Apache License 2.0 licenc alatt terjesztve.", "A YouTrack a JetBrains s.r.o. védjegye. Az UTD független projekt, nem áll kapcsolatban a JetBrains céggel, és azt a JetBrains nem támogatja.", "Harmadik féltől származó licencek…"),
    "ro": ("Distribuit sub licența Apache 2.0.", "YouTrack este o marcă comercială a JetBrains s.r.o. UTD este un proiect independent, neafiliat cu JetBrains și neaprobat de aceasta.", "Licențe terțe…"),
    "hr": ("Distribuira se pod licencom Apache 2.0.", "YouTrack je zaštitni znak tvrtke JetBrains s.r.o. UTD je neovisan projekt koji nije povezan s tvrtkom JetBrains niti ga ona podržava.", "Licence trećih strana…"),
    "bg": ("Разпространява се под лиценза Apache 2.0.", "YouTrack е търговска марка на JetBrains s.r.o. UTD е независим проект, който не е свързан с JetBrains и не е одобрен от JetBrains.", "Лицензи на трети страни…"),
    "el": ("Διανέμεται με την άδεια Apache 2.0.", "Το YouTrack είναι εμπορικό σήμα της JetBrains s.r.o. Το UTD είναι ανεξάρτητο έργο, χωρίς σχέση με την JetBrains και χωρίς την έγκρισή της.", "Άδειες τρίτων…"),
    "tr": ("Apache Lisansı 2.0 kapsamında dağıtılmaktadır.", "YouTrack, JetBrains s.r.o. şirketinin ticari markasıdır. UTD, JetBrains ile bağlantılı olmayan ve JetBrains tarafından onaylanmayan bağımsız bir projedir.", "Üçüncü Taraf Lisansları…"),
    "ru": ("Распространяется по лицензии Apache 2.0.", "YouTrack является товарным знаком JetBrains s.r.o. UTD — независимый проект, не связанный с JetBrains и не одобренный ею.", "Лицензии сторонних компонентов…"),
    "uk": ("Розповсюджується за ліцензією Apache 2.0.", "YouTrack є торговельною маркою JetBrains s.r.o. UTD — незалежний проєкт, не пов’язаний із JetBrains і не схвалений нею.", "Ліцензії сторонніх компонентів…"),
    "ar": ("يُوزَّع بموجب ترخيص Apache 2.0.", "YouTrack علامة تجارية لشركة JetBrains s.r.o. ‏UTD مشروع مستقل غير تابع لشركة JetBrains وغير معتمد منها.", "تراخيص الجهات الخارجية…"),
    "he": ("מופץ תחת רישיון Apache 2.0.", "YouTrack הוא סימן מסחרי של JetBrains s.r.o.‏ UTD הוא פרויקט עצמאי שאינו קשור ל-JetBrains ואינו מאושר על ידה.", "רישיונות צד שלישי…"),
    "hi": ("Apache License 2.0 के अंतर्गत वितरित।", "YouTrack, JetBrains s.r.o. का ट्रेडमार्क है। UTD एक स्वतंत्र प्रोजेक्ट है, जो JetBrains से संबद्ध नहीं है और न ही JetBrains द्वारा समर्थित है।", "तृतीय-पक्ष लाइसेंस…"),
    "th": ("เผยแพร่ภายใต้สัญญาอนุญาต Apache 2.0", "YouTrack เป็นเครื่องหมายการค้าของ JetBrains s.r.o. UTD เป็นโปรเจกต์อิสระ ไม่มีส่วนเกี่ยวข้องหรือได้รับการรับรองจาก JetBrains", "สัญญาอนุญาตของบุคคลที่สาม…"),
    "vi": ("Được phân phối theo Giấy phép Apache 2.0.", "YouTrack là nhãn hiệu của JetBrains s.r.o. UTD là một dự án độc lập, không liên kết với và không được JetBrains xác nhận.", "Giấy phép của bên thứ ba…"),
    "id": ("Didistribusikan di bawah Lisensi Apache 2.0.", "YouTrack adalah merek dagang JetBrains s.r.o. UTD adalah proyek independen yang tidak berafiliasi dengan atau didukung oleh JetBrains.", "Lisensi Pihak Ketiga…"),
    "ms": ("Diedarkan di bawah Lesen Apache 2.0.", "YouTrack ialah tanda dagangan JetBrains s.r.o. UTD ialah projek bebas yang tidak bergabung dengan atau disokong oleh JetBrains.", "Lesen Pihak Ketiga…"),
    "ja": ("Apache License 2.0 のもとで配布されています。", "YouTrack は JetBrains s.r.o. の商標です。UTD は独立したプロジェクトであり、JetBrains との提携や JetBrains による承認はありません。", "サードパーティライセンス…"),
    "ko": ("Apache License 2.0에 따라 배포됩니다.", "YouTrack은 JetBrains s.r.o.의 상표입니다. UTD는 독립 프로젝트로, JetBrains와 제휴하거나 JetBrains의 보증을 받지 않았습니다.", "타사 라이선스…"),
    "zh-Hans": ("根据 Apache License 2.0 分发。", "YouTrack 是 JetBrains s.r.o. 的商标。UTD 是一个独立项目，与 JetBrains 无关联，也未获得 JetBrains 的认可。", "第三方许可…"),
    "zh-Hant": ("依據 Apache License 2.0 散布。", "YouTrack 是 JetBrains s.r.o. 的商標。UTD 是獨立專案，與 JetBrains 無關聯，亦未獲 JetBrains 認可。", "第三方授權…"),
    "ca": ("Distribuït sota la llicència Apache 2.0.", "YouTrack és una marca comercial de JetBrains s.r.o. UTD és un projecte independent, no afiliat ni avalat per JetBrains.", "Llicències de tercers…"),
}


# Desktop notifications. The last entry is the native menu item, the others
# are Flutter keys. {name} and {author} are placeholders.
NOTIF_FLUTTER_KEYS = [
    "notificationsTitle",
    "notificationsIntro",
    "tokenLabel",
    "tokenHelp",
    "openTokenPage",
    "save",
    "tokenInvalid",
    "notificationsEnabled",
    "notificationsDisabled",
    "updatedBy",
    "newActivity",
]
NOTIF_NATIVE_KEY = "menu.notifications"
PLACEHOLDERS = {"notificationsEnabled": "name", "updatedBy": "author"}

NOTIF = {
    "en": ("Desktop notifications", "UTD checks your YouTrack notification center every minute and shows new notifications on your desktop. This requires a permanent token. Leave the field empty to turn notifications off.", "Permanent token", "In YouTrack: Profile › Account Security › New token, with the YouTrack scope.", "Create a token", "Save", "The server rejected this token.", "Notifications enabled for {name}.", "Notifications turned off.", "Updated by {author}", "New activity", "Notifications…"),
    "fr": ("Notifications de bureau", "UTD consulte votre centre de notifications YouTrack chaque minute et affiche les nouvelles notifications sur votre bureau. Un jeton permanent est nécessaire. Laissez le champ vide pour désactiver les notifications.", "Jeton permanent", "Dans YouTrack : Profil › Sécurité du compte › Nouveau jeton, avec la portée YouTrack.", "Créer un jeton", "Enregistrer", "Le serveur a refusé ce jeton.", "Notifications activées pour {name}.", "Notifications désactivées.", "Mis à jour par {author}", "Nouvelle activité", "Notifications…"),
    "de": ("Desktop-Benachrichtigungen", "UTD prüft jede Minute Ihr YouTrack-Benachrichtigungscenter und zeigt neue Benachrichtigungen auf Ihrem Desktop an. Dazu ist ein permanentes Token erforderlich. Lassen Sie das Feld leer, um Benachrichtigungen zu deaktivieren.", "Permanentes Token", "In YouTrack: Profil › Kontosicherheit › Neues Token, mit dem Bereich YouTrack.", "Token erstellen", "Speichern", "Der Server hat dieses Token abgelehnt.", "Benachrichtigungen für {name} aktiviert.", "Benachrichtigungen deaktiviert.", "Aktualisiert von {author}", "Neue Aktivität", "Benachrichtigungen …"),
    "es": ("Notificaciones de escritorio", "UTD consulta cada minuto tu centro de notificaciones de YouTrack y muestra las nuevas notificaciones en el escritorio. Se necesita un token permanente. Deja el campo vacío para desactivar las notificaciones.", "Token permanente", "En YouTrack: Perfil › Seguridad de la cuenta › Nuevo token, con el ámbito YouTrack.", "Crear un token", "Guardar", "El servidor ha rechazado este token.", "Notificaciones activadas para {name}.", "Notificaciones desactivadas.", "Actualizado por {author}", "Nueva actividad", "Notificaciones…"),
    "it": ("Notifiche desktop", "UTD controlla ogni minuto il centro notifiche di YouTrack e mostra le nuove notifiche sul desktop. È necessario un token permanente. Lascia il campo vuoto per disattivare le notifiche.", "Token permanente", "In YouTrack: Profilo › Sicurezza dell'account › Nuovo token, con ambito YouTrack.", "Crea un token", "Salva", "Il server ha rifiutato questo token.", "Notifiche attivate per {name}.", "Notifiche disattivate.", "Aggiornato da {author}", "Nuova attività", "Notifiche…"),
    "pt-BR": ("Notificações na área de trabalho", "O UTD verifica a cada minuto sua central de notificações do YouTrack e exibe as novas notificações na área de trabalho. É necessário um token permanente. Deixe o campo vazio para desativar as notificações.", "Token permanente", "No YouTrack: Perfil › Segurança da conta › Novo token, com o escopo YouTrack.", "Criar um token", "Salvar", "O servidor recusou este token.", "Notificações ativadas para {name}.", "Notificações desativadas.", "Atualizado por {author}", "Nova atividade", "Notificações…"),
    "pt-PT": ("Notificações no ambiente de trabalho", "O UTD verifica a cada minuto o seu centro de notificações do YouTrack e mostra as novas notificações no ambiente de trabalho. É necessário um token permanente. Deixe o campo vazio para desativar as notificações.", "Token permanente", "No YouTrack: Perfil › Segurança da conta › Novo token, com o âmbito YouTrack.", "Criar um token", "Guardar", "O servidor recusou este token.", "Notificações ativadas para {name}.", "Notificações desativadas.", "Atualizado por {author}", "Nova atividade", "Notificações…"),
    "nl": ("Bureaubladmeldingen", "UTD controleert elke minuut je YouTrack-meldingencentrum en toont nieuwe meldingen op je bureaublad. Hiervoor is een permanent token nodig. Laat het veld leeg om meldingen uit te schakelen.", "Permanent token", "In YouTrack: Profiel › Accountbeveiliging › Nieuw token, met het bereik YouTrack.", "Token aanmaken", "Opslaan", "De server heeft dit token geweigerd.", "Meldingen ingeschakeld voor {name}.", "Meldingen uitgeschakeld.", "Bijgewerkt door {author}", "Nieuwe activiteit", "Meldingen…"),
    "sv": ("Skrivbordsnotiser", "UTD kontrollerar ditt notiscenter i YouTrack varje minut och visar nya notiser på skrivbordet. En permanent token krävs. Lämna fältet tomt för att stänga av notiser.", "Permanent token", "I YouTrack: Profil › Kontosäkerhet › Ny token, med omfånget YouTrack.", "Skapa en token", "Spara", "Servern avvisade denna token.", "Notiser aktiverade för {name}.", "Notiser avstängda.", "Uppdaterad av {author}", "Ny aktivitet", "Notiser…"),
    "da": ("Skrivebordsnotifikationer", "UTD tjekker dit YouTrack-notifikationscenter hvert minut og viser nye notifikationer på skrivebordet. Det kræver et permanent token. Lad feltet være tomt for at slå notifikationer fra.", "Permanent token", "I YouTrack: Profil › Kontosikkerhed › Nyt token, med omfanget YouTrack.", "Opret et token", "Gem", "Serveren afviste dette token.", "Notifikationer slået til for {name}.", "Notifikationer slået fra.", "Opdateret af {author}", "Ny aktivitet", "Notifikationer…"),
    "nb": ("Skrivebordsvarsler", "UTD sjekker varselsenteret ditt i YouTrack hvert minutt og viser nye varsler på skrivebordet. Dette krever et permanent token. La feltet stå tomt for å slå av varsler.", "Permanent token", "I YouTrack: Profil › Kontosikkerhet › Nytt token, med omfanget YouTrack.", "Opprett et token", "Lagre", "Serveren avviste dette tokenet.", "Varsler slått på for {name}.", "Varsler slått av.", "Oppdatert av {author}", "Ny aktivitet", "Varsler…"),
    "fi": ("Työpöytäilmoitukset", "UTD tarkistaa YouTrackin ilmoituskeskuksen minuutin välein ja näyttää uudet ilmoitukset työpöydällä. Tämä vaatii pysyvän tunnuksen. Jätä kenttä tyhjäksi, jos haluat poistaa ilmoitukset käytöstä.", "Pysyvä tunnus", "YouTrackissa: Profiili › Tilin suojaus › Uusi tunnus, laajuutena YouTrack.", "Luo tunnus", "Tallenna", "Palvelin hylkäsi tämän tunnuksen.", "Ilmoitukset otettu käyttöön käyttäjälle {name}.", "Ilmoitukset poistettu käytöstä.", "Päivittänyt: {author}", "Uutta toimintaa", "Ilmoitukset…"),
    "pl": ("Powiadomienia na biurku", "UTD co minutę sprawdza centrum powiadomień YouTrack i wyświetla nowe powiadomienia na biurku. Wymagany jest token stały. Pozostaw pole puste, aby wyłączyć powiadomienia.", "Token stały", "W YouTrack: Profil › Bezpieczeństwo konta › Nowy token, z zakresem YouTrack.", "Utwórz token", "Zapisz", "Serwer odrzucił ten token.", "Powiadomienia włączone dla: {name}.", "Powiadomienia wyłączone.", "Zaktualizowane przez: {author}", "Nowa aktywność", "Powiadomienia…"),
    "cs": ("Oznámení na ploše", "UTD každou minutu kontroluje centrum oznámení YouTrack a zobrazuje nová oznámení na ploše. Je potřeba trvalý token. Chcete-li oznámení vypnout, ponechte pole prázdné.", "Trvalý token", "V YouTracku: Profil › Zabezpečení účtu › Nový token, s rozsahem YouTrack.", "Vytvořit token", "Uložit", "Server tento token odmítl.", "Oznámení zapnuta pro uživatele {name}.", "Oznámení vypnuta.", "Aktualizoval(a) {author}", "Nová aktivita", "Oznámení…"),
    "sk": ("Upozornenia na ploche", "UTD každú minútu kontroluje centrum upozornení YouTrack a zobrazuje nové upozornenia na ploche. Vyžaduje sa trvalý token. Ak chcete upozornenia vypnúť, nechajte pole prázdne.", "Trvalý token", "V YouTracku: Profil › Zabezpečenie účtu › Nový token, s rozsahom YouTrack.", "Vytvoriť token", "Uložiť", "Server tento token odmietol.", "Upozornenia zapnuté pre používateľa {name}.", "Upozornenia vypnuté.", "Aktualizoval(a) {author}", "Nová aktivita", "Upozornenia…"),
    "hu": ("Asztali értesítések", "Az UTD percenként ellenőrzi a YouTrack értesítési központját, és megjeleníti az új értesítéseket az asztalon. Ehhez állandó token szükséges. Az értesítések kikapcsolásához hagyja üresen a mezőt.", "Állandó token", "A YouTrackben: Profil › Fiókbiztonság › Új token, YouTrack hatókörrel.", "Token létrehozása", "Mentés", "A szerver elutasította ezt a tokent.", "Értesítések bekapcsolva: {name}.", "Értesítések kikapcsolva.", "Frissítette: {author}", "Új tevékenység", "Értesítések…"),
    "ro": ("Notificări pe desktop", "UTD verifică în fiecare minut centrul de notificări YouTrack și afișează notificările noi pe desktop. Este necesar un token permanent. Lăsați câmpul gol pentru a dezactiva notificările.", "Token permanent", "În YouTrack: Profil › Securitatea contului › Token nou, cu domeniul YouTrack.", "Creați un token", "Salvați", "Serverul a respins acest token.", "Notificări activate pentru {name}.", "Notificări dezactivate.", "Actualizat de {author}", "Activitate nouă", "Notificări…"),
    "hr": ("Obavijesti na radnoj površini", "UTD svake minute provjerava vaš YouTrack centar obavijesti i prikazuje nove obavijesti na radnoj površini. Potreban je trajni token. Ostavite polje prazno kako biste isključili obavijesti.", "Trajni token", "U YouTracku: Profil › Sigurnost računa › Novi token, s opsegom YouTrack.", "Izradi token", "Spremi", "Poslužitelj je odbio ovaj token.", "Obavijesti uključene za {name}.", "Obavijesti isključene.", "Ažurirao/la {author}", "Nova aktivnost", "Obavijesti…"),
    "bg": ("Известия на работния плот", "UTD проверява всяка минута центъра за известия на YouTrack и показва новите известия на работния плот. Необходим е постоянен токен. Оставете полето празно, за да изключите известията.", "Постоянен токен", "В YouTrack: Профил › Сигурност на акаунта › Нов токен, с обхват YouTrack.", "Създаване на токен", "Запази", "Сървърът отхвърли този токен.", "Известията са включени за {name}.", "Известията са изключени.", "Обновено от {author}", "Нова активност", "Известия…"),
    "el": ("Ειδοποιήσεις επιφάνειας εργασίας", "Το UTD ελέγχει κάθε λεπτό το κέντρο ειδοποιήσεων του YouTrack και εμφανίζει τις νέες ειδοποιήσεις στην επιφάνεια εργασίας. Απαιτείται μόνιμο διακριτικό. Αφήστε το πεδίο κενό για να απενεργοποιήσετε τις ειδοποιήσεις.", "Μόνιμο διακριτικό", "Στο YouTrack: Προφίλ › Ασφάλεια λογαριασμού › Νέο διακριτικό, με εμβέλεια YouTrack.", "Δημιουργία διακριτικού", "Αποθήκευση", "Ο διακομιστής απέρριψε αυτό το διακριτικό.", "Οι ειδοποιήσεις ενεργοποιήθηκαν για τον χρήστη {name}.", "Οι ειδοποιήσεις απενεργοποιήθηκαν.", "Ενημερώθηκε από {author}", "Νέα δραστηριότητα", "Ειδοποιήσεις…"),
    "tr": ("Masaüstü bildirimleri", "UTD, YouTrack bildirim merkezinizi her dakika kontrol eder ve yeni bildirimleri masaüstünde gösterir. Kalıcı bir belirteç gerekir. Bildirimleri kapatmak için alanı boş bırakın.", "Kalıcı belirteç", "YouTrack'te: Profil › Hesap Güvenliği › Yeni belirteç, YouTrack kapsamıyla.", "Belirteç oluştur", "Kaydet", "Sunucu bu belirteci reddetti.", "{name} için bildirimler açıldı.", "Bildirimler kapatıldı.", "Güncelleyen: {author}", "Yeni etkinlik", "Bildirimler…"),
    "ru": ("Уведомления на рабочем столе", "UTD каждую минуту проверяет центр уведомлений YouTrack и показывает новые уведомления на рабочем столе. Требуется постоянный токен. Оставьте поле пустым, чтобы отключить уведомления.", "Постоянный токен", "В YouTrack: Профиль › Безопасность аккаунта › Новый токен, с областью YouTrack.", "Создать токен", "Сохранить", "Сервер отклонил этот токен.", "Уведомления включены для {name}.", "Уведомления отключены.", "Обновлено: {author}", "Новая активность", "Уведомления…"),
    "uk": ("Сповіщення на робочому столі", "UTD щохвилини перевіряє центр сповіщень YouTrack і показує нові сповіщення на робочому столі. Потрібен постійний токен. Залиште поле порожнім, щоб вимкнути сповіщення.", "Постійний токен", "У YouTrack: Профіль › Безпека облікового запису › Новий токен, з областю YouTrack.", "Створити токен", "Зберегти", "Сервер відхилив цей токен.", "Сповіщення увімкнено для {name}.", "Сповіщення вимкнено.", "Оновлено: {author}", "Нова активність", "Сповіщення…"),
    "ar": ("إشعارات سطح المكتب", "يتحقق UTD كل دقيقة من مركز إشعارات YouTrack ويعرض الإشعارات الجديدة على سطح المكتب. يلزم رمز مميز دائم. اترك الحقل فارغًا لإيقاف الإشعارات.", "رمز مميز دائم", "في YouTrack: الملف الشخصي › أمان الحساب › رمز مميز جديد، بنطاق YouTrack.", "إنشاء رمز مميز", "حفظ", "رفض الخادم هذا الرمز المميز.", "تم تشغيل الإشعارات لـ {name}.", "تم إيقاف الإشعارات.", "حدّثه {author}", "نشاط جديد", "الإشعارات…"),
    "he": ("התראות בשולחן העבודה", "UTD בודק בכל דקה את מרכז ההתראות של YouTrack ומציג התראות חדשות בשולחן העבודה. נדרש אסימון קבוע. השאירו את השדה ריק כדי לכבות את ההתראות.", "אסימון קבוע", "ב-YouTrack: פרופיל › אבטחת חשבון › אסימון חדש, עם ההיקף YouTrack.", "יצירת אסימון", "שמירה", "השרת דחה את האסימון הזה.", "ההתראות הופעלו עבור {name}.", "ההתראות כובו.", "עודכן על ידי {author}", "פעילות חדשה", "התראות…"),
    "hi": ("डेस्कटॉप सूचनाएँ", "UTD हर मिनट आपके YouTrack सूचना केंद्र की जाँच करता है और नई सूचनाएँ डेस्कटॉप पर दिखाता है। इसके लिए एक स्थायी टोकन आवश्यक है। सूचनाएँ बंद करने के लिए फ़ील्ड खाली छोड़ दें।", "स्थायी टोकन", "YouTrack में: प्रोफ़ाइल › खाता सुरक्षा › नया टोकन, YouTrack स्कोप के साथ।", "टोकन बनाएँ", "सहेजें", "सर्वर ने यह टोकन अस्वीकार कर दिया।", "{name} के लिए सूचनाएँ चालू की गईं।", "सूचनाएँ बंद की गईं।", "{author} द्वारा अपडेट किया गया", "नई गतिविधि", "सूचनाएँ…"),
    "th": ("การแจ้งเตือนบนเดสก์ท็อป", "UTD ตรวจสอบศูนย์การแจ้งเตือน YouTrack ของคุณทุกนาทีและแสดงการแจ้งเตือนใหม่บนเดสก์ท็อป ต้องใช้โทเค็นถาวร เว้นช่องว่างไว้เพื่อปิดการแจ้งเตือน", "โทเค็นถาวร", "ใน YouTrack: โปรไฟล์ › ความปลอดภัยของบัญชี › โทเค็นใหม่ โดยใช้ขอบเขต YouTrack", "สร้างโทเค็น", "บันทึก", "เซิร์ฟเวอร์ปฏิเสธโทเค็นนี้", "เปิดการแจ้งเตือนสำหรับ {name} แล้ว", "ปิดการแจ้งเตือนแล้ว", "อัปเดตโดย {author}", "กิจกรรมใหม่", "การแจ้งเตือน…"),
    "vi": ("Thông báo trên màn hình", "UTD kiểm tra trung tâm thông báo YouTrack của bạn mỗi phút và hiển thị thông báo mới trên màn hình. Cần có token vĩnh viễn. Để trống trường này để tắt thông báo.", "Token vĩnh viễn", "Trong YouTrack: Hồ sơ › Bảo mật tài khoản › Token mới, với phạm vi YouTrack.", "Tạo token", "Lưu", "Máy chủ đã từ chối token này.", "Đã bật thông báo cho {name}.", "Đã tắt thông báo.", "Được cập nhật bởi {author}", "Hoạt động mới", "Thông báo…"),
    "id": ("Notifikasi desktop", "UTD memeriksa pusat notifikasi YouTrack Anda setiap menit dan menampilkan notifikasi baru di desktop. Diperlukan token permanen. Biarkan kolom kosong untuk menonaktifkan notifikasi.", "Token permanen", "Di YouTrack: Profil › Keamanan Akun › Token baru, dengan cakupan YouTrack.", "Buat token", "Simpan", "Server menolak token ini.", "Notifikasi diaktifkan untuk {name}.", "Notifikasi dinonaktifkan.", "Diperbarui oleh {author}", "Aktivitas baru", "Notifikasi…"),
    "ms": ("Pemberitahuan desktop", "UTD menyemak pusat pemberitahuan YouTrack anda setiap minit dan memaparkan pemberitahuan baharu pada desktop. Token kekal diperlukan. Biarkan medan kosong untuk mematikan pemberitahuan.", "Token kekal", "Dalam YouTrack: Profil › Keselamatan Akaun › Token baharu, dengan skop YouTrack.", "Cipta token", "Simpan", "Pelayan menolak token ini.", "Pemberitahuan dihidupkan untuk {name}.", "Pemberitahuan dimatikan.", "Dikemas kini oleh {author}", "Aktiviti baharu", "Pemberitahuan…"),
    "ja": ("デスクトップ通知", "UTD は YouTrack の通知センターを 1 分ごとに確認し、新しい通知をデスクトップに表示します。永続トークンが必要です。通知をオフにするには、フィールドを空のままにしてください。", "永続トークン", "YouTrack で: プロフィール › アカウントのセキュリティ › 新しいトークン（スコープ: YouTrack）", "トークンを作成", "保存", "サーバーがこのトークンを拒否しました。", "{name} の通知を有効にしました。", "通知をオフにしました。", "{author} が更新", "新しいアクティビティ", "通知…"),
    "ko": ("데스크탑 알림", "UTD는 1분마다 YouTrack 알림 센터를 확인하여 새 알림을 데스크탑에 표시합니다. 영구 토큰이 필요합니다. 알림을 끄려면 필드를 비워 두십시오.", "영구 토큰", "YouTrack에서: 프로필 › 계정 보안 › 새 토큰(범위: YouTrack)", "토큰 생성", "저장", "서버가 이 토큰을 거부했습니다.", "{name}님의 알림이 켜졌습니다.", "알림이 꺼졌습니다.", "{author}님이 업데이트함", "새 활동", "알림…"),
    "zh-Hans": ("桌面通知", "UTD 每分钟检查一次您的 YouTrack 通知中心，并在桌面上显示新通知。需要永久令牌。将此字段留空即可关闭通知。", "永久令牌", "在 YouTrack 中：个人资料 › 账户安全 › 新令牌，范围选择 YouTrack。", "创建令牌", "保存", "服务器拒绝了此令牌。", "已为 {name} 开启通知。", "通知已关闭。", "由 {author} 更新", "新动态", "通知…"),
    "zh-Hant": ("桌面通知", "UTD 每分鐘檢查一次你的 YouTrack 通知中心，並在桌面上顯示新通知。需要永久權杖。將此欄位留空即可關閉通知。", "永久權杖", "在 YouTrack 中：個人檔案 › 帳號安全性 › 新權杖，範圍選擇 YouTrack。", "建立權杖", "儲存", "伺服器拒絕了此權杖。", "已為 {name} 開啟通知。", "通知已關閉。", "由 {author} 更新", "新動態", "通知…"),
    "ca": ("Notificacions d'escriptori", "UTD comprova cada minut el centre de notificacions de YouTrack i mostra les notificacions noves a l'escriptori. Cal un testimoni permanent. Deixa el camp buit per desactivar les notificacions.", "Testimoni permanent", "A YouTrack: Perfil › Seguretat del compte › Testimoni nou, amb l'àmbit YouTrack.", "Crea un testimoni", "Desa", "El servidor ha rebutjat aquest testimoni.", "Notificacions activades per a {name}.", "Notificacions desactivades.", "Actualitzat per {author}", "Activitat nova", "Notificacions…"),
}


# Notification status shown in the notification settings dialog.
# Placeholders: {time}, {count}, {error}.
STATUS_KEYS = [
    "statusChecking",
    "statusOk",
    "statusKeychainError",
    "statusError",
    "statusPermissionDenied",
    "openSystemSettings",
]

STATUS = {
    "en": ("Checking…", "Last check at {time}. Unread notifications: {count}.", "The saved token could not be read from the system keychain. Enter it again and save.", "Last check failed: {error}", "The system blocks notifications from UTD. Allow them in the system settings.", "Open system settings"),
    "fr": ("Vérification…", "Dernière vérification à {time}. Notifications non lues : {count}.", "Le jeton enregistré n'a pas pu être lu dans le trousseau du système. Saisissez-le à nouveau et enregistrez.", "La dernière vérification a échoué : {error}", "Le système bloque les notifications d'UTD. Autorisez-les dans les réglages du système.", "Ouvrir les réglages du système"),
    "de": ("Wird geprüft …", "Letzte Prüfung um {time}. Ungelesene Benachrichtigungen: {count}.", "Das gespeicherte Token konnte nicht aus dem Schlüsselbund des Systems gelesen werden. Geben Sie es erneut ein und speichern Sie.", "Letzte Prüfung fehlgeschlagen: {error}", "Das System blockiert Benachrichtigungen von UTD. Erlauben Sie sie in den Systemeinstellungen.", "Systemeinstellungen öffnen"),
    "es": ("Comprobando…", "Última comprobación a las {time}. Notificaciones sin leer: {count}.", "No se pudo leer el token guardado en el llavero del sistema. Vuelve a introducirlo y guárdalo.", "La última comprobación falló: {error}", "El sistema bloquea las notificaciones de UTD. Permítelas en los ajustes del sistema.", "Abrir los ajustes del sistema"),
    "it": ("Verifica in corso…", "Ultima verifica alle {time}. Notifiche non lette: {count}.", "Impossibile leggere il token salvato dal portachiavi di sistema. Inseriscilo di nuovo e salva.", "Ultima verifica non riuscita: {error}", "Il sistema blocca le notifiche di UTD. Consentile nelle impostazioni di sistema.", "Apri impostazioni di sistema"),
    "pt-BR": ("Verificando…", "Última verificação às {time}. Notificações não lidas: {count}.", "Não foi possível ler o token salvo nas chaves do sistema. Digite-o novamente e salve.", "A última verificação falhou: {error}", "O sistema está bloqueando as notificações do UTD. Permita-as nos ajustes do sistema.", "Abrir ajustes do sistema"),
    "pt-PT": ("A verificar…", "Última verificação às {time}. Notificações não lidas: {count}.", "Não foi possível ler o token guardado no porta-chaves do sistema. Introduza-o novamente e guarde.", "A última verificação falhou: {error}", "O sistema bloqueia as notificações do UTD. Permita-as nas definições do sistema.", "Abrir definições do sistema"),
    "nl": ("Controleren…", "Laatste controle om {time}. Ongelezen meldingen: {count}.", "Het opgeslagen token kon niet uit de sleutelhanger van het systeem worden gelezen. Voer het opnieuw in en sla op.", "Laatste controle mislukt: {error}", "Het systeem blokkeert meldingen van UTD. Sta ze toe in de systeeminstellingen.", "Systeeminstellingen openen"),
    "sv": ("Kontrollerar…", "Senaste kontroll kl. {time}. Olästa notiser: {count}.", "Den sparade token kunde inte läsas från systemets nyckelring. Ange den igen och spara.", "Senaste kontrollen misslyckades: {error}", "Systemet blockerar notiser från UTD. Tillåt dem i systeminställningarna.", "Öppna systeminställningar"),
    "da": ("Tjekker…", "Seneste tjek kl. {time}. Ulæste notifikationer: {count}.", "Det gemte token kunne ikke læses fra systemets nøglering. Indtast det igen, og gem.", "Seneste tjek mislykkedes: {error}", "Systemet blokerer notifikationer fra UTD. Tillad dem i systemindstillingerne.", "Åbn systemindstillinger"),
    "nb": ("Sjekker…", "Siste sjekk kl. {time}. Uleste varsler: {count}.", "Det lagrede tokenet kunne ikke leses fra systemets nøkkelring. Skriv det inn på nytt og lagre.", "Siste sjekk mislyktes: {error}", "Systemet blokkerer varsler fra UTD. Tillat dem i systeminnstillingene.", "Åpne systeminnstillinger"),
    "fi": ("Tarkistetaan…", "Viimeisin tarkistus klo {time}. Lukemattomia ilmoituksia: {count}.", "Tallennettua tunnusta ei voitu lukea järjestelmän avainnipusta. Anna se uudelleen ja tallenna.", "Viimeisin tarkistus epäonnistui: {error}", "Järjestelmä estää UTD:n ilmoitukset. Salli ne järjestelmäasetuksissa.", "Avaa järjestelmäasetukset"),
    "pl": ("Sprawdzanie…", "Ostatnie sprawdzenie o {time}. Nieprzeczytane powiadomienia: {count}.", "Nie udało się odczytać zapisanego tokenu z pęku kluczy systemu. Wpisz go ponownie i zapisz.", "Ostatnie sprawdzenie nie powiodło się: {error}", "System blokuje powiadomienia UTD. Zezwól na nie w ustawieniach systemu.", "Otwórz ustawienia systemu"),
    "cs": ("Probíhá kontrola…", "Poslední kontrola v {time}. Nepřečtená oznámení: {count}.", "Uložený token se nepodařilo načíst ze systémové klíčenky. Zadejte ho znovu a uložte.", "Poslední kontrola selhala: {error}", "Systém blokuje oznámení aplikace UTD. Povolte je v nastavení systému.", "Otevřít nastavení systému"),
    "sk": ("Prebieha kontrola…", "Posledná kontrola o {time}. Neprečítané upozornenia: {count}.", "Uložený token sa nepodarilo načítať zo systémovej kľúčenky. Zadajte ho znova a uložte.", "Posledná kontrola zlyhala: {error}", "Systém blokuje upozornenia aplikácie UTD. Povoľte ich v nastaveniach systému.", "Otvoriť nastavenia systému"),
    "hu": ("Ellenőrzés…", "Utolsó ellenőrzés: {time}. Olvasatlan értesítések: {count}.", "A mentett tokent nem sikerült kiolvasni a rendszer kulcskarikájából. Adja meg újra, és mentse.", "Az utolsó ellenőrzés sikertelen: {error}", "A rendszer letiltja az UTD értesítéseit. Engedélyezze őket a rendszerbeállításokban.", "Rendszerbeállítások megnyitása"),
    "ro": ("Se verifică…", "Ultima verificare la {time}. Notificări necitite: {count}.", "Tokenul salvat nu a putut fi citit din portcheiul sistemului. Introduceți-l din nou și salvați.", "Ultima verificare a eșuat: {error}", "Sistemul blochează notificările UTD. Permiteți-le în setările sistemului.", "Deschideți setările sistemului"),
    "hr": ("Provjera…", "Posljednja provjera u {time}. Nepročitane obavijesti: {count}.", "Spremljeni token nije moguće pročitati iz privjeska ključeva sustava. Unesite ga ponovno i spremite.", "Posljednja provjera nije uspjela: {error}", "Sustav blokira obavijesti aplikacije UTD. Dopustite ih u postavkama sustava.", "Otvori postavke sustava"),
    "bg": ("Проверка…", "Последна проверка в {time}. Непрочетени известия: {count}.", "Запазеният токен не можа да бъде прочетен от ключодържателя на системата. Въведете го отново и запазете.", "Последната проверка е неуспешна: {error}", "Системата блокира известията на UTD. Разрешете ги в системните настройки.", "Отваряне на системните настройки"),
    "el": ("Έλεγχος…", "Τελευταίος έλεγχος στις {time}. Μη αναγνωσμένες ειδοποιήσεις: {count}.", "Δεν ήταν δυνατή η ανάγνωση του αποθηκευμένου διακριτικού από την κλειδοθήκη του συστήματος. Εισαγάγετέ το ξανά και αποθηκεύστε.", "Ο τελευταίος έλεγχος απέτυχε: {error}", "Το σύστημα αποκλείει τις ειδοποιήσεις του UTD. Επιτρέψτε τις στις ρυθμίσεις συστήματος.", "Άνοιγμα ρυθμίσεων συστήματος"),
    "tr": ("Kontrol ediliyor…", "Son kontrol: {time}. Okunmamış bildirimler: {count}.", "Kaydedilen belirteç sistem anahtar zincirinden okunamadı. Yeniden girip kaydedin.", "Son kontrol başarısız oldu: {error}", "Sistem UTD bildirimlerini engelliyor. Sistem ayarlarından izin verin.", "Sistem ayarlarını aç"),
    "ru": ("Проверка…", "Последняя проверка в {time}. Непрочитанные уведомления: {count}.", "Не удалось прочитать сохранённый токен из системной связки ключей. Введите его снова и сохраните.", "Последняя проверка не удалась: {error}", "Система блокирует уведомления UTD. Разрешите их в настройках системы.", "Открыть настройки системы"),
    "uk": ("Перевірка…", "Остання перевірка о {time}. Непрочитані сповіщення: {count}.", "Не вдалося прочитати збережений токен із системної в'язки ключів. Введіть його знову та збережіть.", "Остання перевірка не вдалася: {error}", "Система блокує сповіщення UTD. Дозвольте їх у налаштуваннях системи.", "Відкрити налаштування системи"),
    "ar": ("جارٍ التحقق…", "آخر تحقق في {time}. الإشعارات غير المقروءة: {count}.", "تعذرت قراءة الرمز المميز المحفوظ من سلسلة مفاتيح النظام. أدخله مرة أخرى واحفظه.", "فشل آخر تحقق: {error}", "يحظر النظام إشعارات UTD. اسمح بها في إعدادات النظام.", "فتح إعدادات النظام"),
    "he": ("בודק…", "בדיקה אחרונה ב-{time}. התראות שלא נקראו: {count}.", "לא ניתן היה לקרוא את האסימון השמור ממחזיק המפתחות של המערכת. הזינו אותו שוב ושמרו.", "הבדיקה האחרונה נכשלה: {error}", "המערכת חוסמת את ההתראות של UTD. אפשרו אותן בהגדרות המערכת.", "פתיחת הגדרות המערכת"),
    "hi": ("जाँच की जा रही है…", "अंतिम जाँच {time} पर। अपठित सूचनाएँ: {count}।", "सहेजा गया टोकन सिस्टम कीचेन से पढ़ा नहीं जा सका। इसे फिर से दर्ज करें और सहेजें।", "अंतिम जाँच विफल रही: {error}", "सिस्टम UTD की सूचनाओं को रोक रहा है। सिस्टम सेटिंग्स में इन्हें अनुमति दें।", "सिस्टम सेटिंग्स खोलें"),
    "th": ("กำลังตรวจสอบ…", "ตรวจสอบล่าสุดเมื่อ {time} การแจ้งเตือนที่ยังไม่ได้อ่าน: {count}", "ไม่สามารถอ่านโทเค็นที่บันทึกไว้จากพวงกุญแจของระบบได้ ป้อนโทเค็นอีกครั้งแล้วบันทึก", "การตรวจสอบล่าสุดล้มเหลว: {error}", "ระบบบล็อกการแจ้งเตือนของ UTD อนุญาตได้ในการตั้งค่าระบบ", "เปิดการตั้งค่าระบบ"),
    "vi": ("Đang kiểm tra…", "Lần kiểm tra cuối lúc {time}. Thông báo chưa đọc: {count}.", "Không thể đọc token đã lưu từ chuỗi khóa của hệ thống. Hãy nhập lại và lưu.", "Lần kiểm tra cuối thất bại: {error}", "Hệ thống đang chặn thông báo của UTD. Hãy cho phép trong cài đặt hệ thống.", "Mở cài đặt hệ thống"),
    "id": ("Memeriksa…", "Pemeriksaan terakhir pukul {time}. Notifikasi belum dibaca: {count}.", "Token yang disimpan tidak dapat dibaca dari rantai kunci sistem. Masukkan lagi lalu simpan.", "Pemeriksaan terakhir gagal: {error}", "Sistem memblokir notifikasi UTD. Izinkan di pengaturan sistem.", "Buka pengaturan sistem"),
    "ms": ("Menyemak…", "Semakan terakhir pada {time}. Pemberitahuan belum dibaca: {count}.", "Token yang disimpan tidak dapat dibaca daripada rantai kunci sistem. Masukkannya semula dan simpan.", "Semakan terakhir gagal: {error}", "Sistem menyekat pemberitahuan UTD. Benarkannya dalam tetapan sistem.", "Buka tetapan sistem"),
    "ja": ("確認中…", "最終確認: {time}。未読の通知: {count}。", "保存されたトークンをシステムのキーチェーンから読み込めませんでした。もう一度入力して保存してください。", "前回の確認に失敗しました: {error}", "システムが UTD の通知をブロックしています。システム設定で許可してください。", "システム設定を開く"),
    "ko": ("확인 중…", "마지막 확인: {time}. 읽지 않은 알림: {count}.", "저장된 토큰을 시스템 키체인에서 읽을 수 없습니다. 다시 입력하고 저장하십시오.", "마지막 확인 실패: {error}", "시스템이 UTD 알림을 차단하고 있습니다. 시스템 설정에서 허용하십시오.", "시스템 설정 열기"),
    "zh-Hans": ("正在检查…", "上次检查时间：{time}。未读通知：{count}。", "无法从系统钥匙串读取已保存的令牌。请重新输入并保存。", "上次检查失败：{error}", "系统已阻止 UTD 的通知。请在系统设置中允许。", "打开系统设置"),
    "zh-Hant": ("正在檢查…", "上次檢查時間：{time}。未讀通知：{count}。", "無法從系統鑰匙圈讀取已儲存的權杖。請重新輸入並儲存。", "上次檢查失敗：{error}", "系統已封鎖 UTD 的通知。請在系統設定中允許。", "打開系統設定"),
    "ca": ("S'està comprovant…", "Darrera comprovació a les {time}. Notificacions no llegides: {count}.", "No s'ha pogut llegir el testimoni desat del clauer del sistema. Torna'l a introduir i desa'l.", "La darrera comprovació ha fallat: {error}", "El sistema bloqueja les notificacions d'UTD. Permet-les a la configuració del sistema.", "Obre la configuració del sistema"),
}


def placeholders(text):
    return sorted(re.findall(r"\{(\w+)\}", text))


def check():
    assert set(STATUS) == set(LANGUAGES), set(STATUS) ^ set(LANGUAGES)
    for lang, values in STATUS.items():
        assert len(values) == len(STATUS_KEYS), lang
        for key, value, english in zip(STATUS_KEYS, values, STATUS["en"]):
            assert placeholders(value) == placeholders(english), f"{lang} {key}: placeholders"
    assert set(NOTIF) == set(LANGUAGES), set(NOTIF) ^ set(LANGUAGES)
    for lang, values in NOTIF.items():
        assert len(values) == len(NOTIF_FLUTTER_KEYS) + 1, lang
        for key, value in zip(NOTIF_FLUTTER_KEYS, values):
            for k, ph in PLACEHOLDERS.items():
                if key == k:
                    assert "{" + ph + "}" in value, f"{lang} {key}: missing {{{ph}}}"
            assert value.count("{") == (1 if key in PLACEHOLDERS else 0), f"{lang} {key}"
    assert set(LEGAL) == set(LANGUAGES), set(LEGAL) ^ set(LANGUAGES)
    for lang, values in LEGAL.items():
        assert len(values) == len(LEGAL_KEYS), lang
        assert "JetBrains s.r.o" in values[1], f"{lang}: trademark owner missing"
    for table, keys in ((FLUTTER, FLUTTER_KEYS), (NATIVE, NATIVE_KEYS)):
        assert set(table) == set(LANGUAGES), set(table) ^ set(LANGUAGES)
        for lang, values in table.items():
            assert len(values) == len(keys), f"{lang}: {len(values)} != {len(keys)}"
    for lang, values in NATIVE.items():
        for key, value in zip(NATIVE_KEYS, values):
            expected = NATIVE["en"][NATIVE_KEYS.index(key)].count("%@")
            assert value.count("%@") == expected, f"{lang} {key}: placeholder mismatch"


def write_arb(lang, arb_locale):
    data = {"@@locale": arb_locale}
    for key, value in zip(FLUTTER_KEYS, FLUTTER[lang]):
        data[key] = value
    license_text, trademark, _ = LEGAL[lang]
    data["legalese"] = f"{license_text}\n\n{trademark}"
    for key, value in zip(NOTIF_FLUTTER_KEYS, NOTIF[lang]):
        data[key] = value
        if lang == "en" and key in PLACEHOLDERS:
            data[f"@{key}"] = {"placeholders": {PLACEHOLDERS[key]: {"type": "String"}}}
    # Menu labels for Windows (system menu) and Linux (context menu), reused
    # from the native macOS menu translations.
    native = dict(zip(NATIVE_KEYS, NATIVE[lang]))
    for key, value in zip(STATUS_KEYS, STATUS[lang]):
        data[key] = value
        if lang == "en" and (names := placeholders(value)):
            data[f"@{key}"] = {"placeholders": {n: {"type": "String"} for n in names}}
    data["menuChangeServer"] = native["menu.changeServer"]
    data["menuNotifications"] = NOTIF[lang][-1]
    data["menuAbout"] = native["menu.about"].replace("%@", "{app}")
    if lang == "en":
        data["@menuAbout"] = {"placeholders": {"app": {"type": "String"}}}
    path = ROOT / "lib" / "l10n" / f"app_{arb_locale}.arb"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def write_strings(lang, lproj):
    def esc(s):
        return s.replace("\\", "\\\\").replace('"', '\\"')

    lines = ["/* Generated by tool/l10n.py — do not edit. */", ""]
    for key, value in [
        *zip(NATIVE_KEYS, NATIVE[lang]),
        *zip(LEGAL_KEYS, LEGAL[lang]),
        (NOTIF_NATIVE_KEY, NOTIF[lang][-1]),
    ]:
        lines.append(f'"{key}" = "{esc(value)}";')
    path = ROOT / "macos" / "Runner" / f"{lproj}.lproj" / "Localizable.strings"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    check()
    for lang, (arb_locale, lproj) in LANGUAGES.items():
        write_arb(lang, arb_locale)
        write_strings(lang, lproj)
    print(f"{len(LANGUAGES)} languages written.")


if __name__ == "__main__":
    main()
