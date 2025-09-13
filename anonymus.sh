#!/bin/bash

echo "[+] بدء إعداد بيئة اختراق مجهولة الهوية..."

# 1. تغيير عنوان MAC
echo "[+] تغيير عنوان MAC..."
interface="eth0" # غيّرها حسب اسم الكرت عندك (مثلاً wlan0 للواي فاي)
ifconfig $interface down
macchanger -r $interface
ifconfig $interface up

# 2. تحديث النظام (اختياري)
echo "[+] تحديث النظام..."
apt update && apt upgrade -y

# 3. تثبيت Tor و Proxychains
echo "[+] تثبيت Tor و Proxychains..."
apt install -y tor proxychains4 macchanger curl firejail

# 4. تعديل ملف إعدادات Proxychains ليستخدم Tor
echo "[+] تعديل إعدادات Proxychains..."
sed -i 's/^#dynamic_chain/dynamic_chain/' /etc/proxychains4.conf
sed -i 's/^strict_chain/#strict_chain/' /etc/proxychains4.conf
sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains4.conf
sed -i 's/socks4.*127.0.0.1 9050/socks5 127.0.0.1 9050/' /etc/proxychains4.conf

# 5. تشغيل Tor
echo "[+] تشغيل خدمة Tor..."
systemctl start tor
systemctl enable tor

# 6. إعداد curl ب User-Agent مزيف
echo "[+] إعداد curl بهوية متخفية..."
alias curl-anon='proxychains curl -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.0.0 Safari/537.36"'

# 7. إعداد Nmap لاستخدام Proxychains (للبورت 80/443)
echo "[+] يمكنك استخدام Nmap كالتالي:"
echo 'proxychains nmap -sT -Pn target.com'

# 8. إعداد Firejail لعزل الأدوات
echo "[+] مثال على تشغيل Firefox في عزل تام:"
echo 'firejail --net=none firefox'

# 9. حذف بيانات تعريف الجهاز (Metadata cleaning tool)
echo "[+] تثبيت exiftool لتنظيف الميتاداتا من الملفات..."
apt install -y libimage-exiftool-perl

# 10. حذف البصمات القديمة
echo "[+] حذف سجلات Bash وسجلات النظام..."
history -c
rm -rf ~/.bash_history /var/log/* /root/.bash_history

echo "[✔] تمت التهيئة بنجاح. استخدم التور، وبروكسي تشينز، وتأكد من MAC متغير قبل أي نشاط."
