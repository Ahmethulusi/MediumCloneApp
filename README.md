
<h1 align="center">📰 MediumCloneApp</h1>
<p align="center"><i>Modern bir Medium.com klonu - Flutter, Node.js ve MongoDB ile geliştirilmiş güçlü bir blog platformu</i></p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.7-blue.svg" />
  <img src="https://img.shields.io/badge/Node.js-Express-green.svg" />
  <img src="https://img.shields.io/badge/MongoDB-Database-brightgreen.svg" />
  <img src="https://img.shields.io/badge/JWT-Auth-yellow.svg" />
  <img src="https://img.shields.io/badge/Dart-3.7-blue.svg" />
  <img src="https://img.shields.io/badge/Admin%20Panel-✓-purple.svg" />
</p>

## 🚀 Proje Hakkında

Bu proje, kullanıcıların makale okuyup paylaşabileceği, kişisel profillerini yönetebileceği ve zengin içerik editörü ile makale yazabileceği modern bir blog platformudur. Uygulama Flutter ile geliştirilmiş olup, arka planda Node.js ve MongoDB kullanmaktadır. Ayrıca kapsamlı bir admin paneli ve tema yönetim sistemi içermektedir.

## ✨ Temel Özellikler

### 🔐 Kimlik Doğrulama & Güvenlik
- JWT tabanlı güvenli kullanıcı girişi ve kaydı
- Şifre sıfırlama ve unutma işlemleri
- Oturum yönetimi ve otomatik çıkış
- Rol tabanlı yetkilendirme (Kullanıcı/Admin)

### 📝 İçerik Yönetimi
- **Rich Text Editor**: Flutter Quill ile gelişmiş makale editörü
- **Görsel Upload**: Makale ve profil fotoğrafı yükleme
- **Kategori Sistemi**: Makale kategorilendirme ve filtreleme
- **Kaydetme**: Makaleleri daha sonra okumak üzere kaydetme
- **Makale Düzenleme**: Yazılan makaleleri düzenleme

### 👥 Sosyal Özellikler
- **Kullanıcı Profilleri**: Detaylı profil sayfaları ve düzenleme
- **Takip Sistemi**: Yazarları takip etme
- **Yorum Sistemi**: Makalelere yorum yapma
- **Önerilen Kullanıcılar**: Takip edilebilecek yazarlar

### 🎨 Tema & Arayüz
- **8 Farklı Tema**: Light, Dark, Retro, Arctic Blue, Coral Sand, Soft Nature ve daha fazlası
- **Dinamik Tema Değiştirme**: Anlık tema geçişleri
- **Responsive Design**: Tüm cihazlarda uyumlu tasarım
- **Admin Tema Yönetimi**: Yöneticiler tarafından özel tema oluşturma

### 📊 Admin Paneli
- **Dashboard**: Kullanıcı ve makale istatistikleri
- **Kullanıcı Yönetimi**: Kullanıcı listesi ve yönetimi
- **Kategori Yönetimi**: Kategori ekleme/düzenleme/silme
- **Tema Yönetimi**: Özel tema oluşturma ve düzenleme
- **Raporlama**: Detaylı analitik raporlar
- **İçerik Moderasyonu**: Şikayet ve rapor yönetimi

### 📈 Raporlama & Analitik
- En popüler makaleler
- En aktif yazarlar
- Kategori bazlı istatistikler
- Toplam kullanıcı ve makale sayıları
- En çok okunan makaleler

## 🛠️ Kullanılan Teknolojiler

### Frontend (Flutter)
- **Flutter**: 3.7.0
- **Dart**: 3.7.0
- **Provider**: State management
- **HTTP**: API istekleri
- **Flutter Quill**: Rich text editor
- **FL Chart**: Grafik ve istatistikler
- **Shared Preferences**: Yerel veri saklama
- **Image Picker**: Görsel seçme ve yükleme

### Backend (Node.js)
- **Node.js & Express.js**: Server framework
- **MongoDB & Mongoose**: Veritabanı
- **JWT**: Token tabanlı kimlik doğrulama
- **bcryptjs**: Şifre hashleme
- **Multer**: Dosya yükleme
- **Nodemailer**: E-posta gönderimi
- **CORS**: Cross-origin istekler

## 📂 Proje Dizini Yapısı
```
MediumCloneApp/
├── frontend/
│ ├── lib/
│ │ ├── components/ # UI bileşenleri
│ │ │ ├── article_card.dart
│ │ │ ├── comment_sheet.dart
│ │ │ ├── html_editor.dart
│ │ │ └── ...
│ │ ├── screens/ # Uygulama ekranları
│ │ │ ├── home_screen.dart
│ │ │ ├── admin_home_screen.dart
│ │ │ ├── article_detail_screen.dart
│ │ │ ├── profile_screen.dart
│ │ │ ├── reports/ # Admin raporları
│ │ │ └── ...
│ │ ├── services/ # API servisleri
│ │ ├── providers/ # State management
│ │ ├── theme/ # Tema dosyaları
│ │ │ ├── app_theme.dart
│ │ │ ├── theme_light.dart
│ │ │ ├── theme_dark.dart
│ │ │ └── ...
│ │ └── utils/ # Yardımcı fonksiyonlar
│ ├── assets/ # Statik dosyalar
│ └── pubspec.yaml # Flutter bağımlılıkları
│
├── backend/
│ ├── models/ # Veritabanı modelleri
│ │ ├── Users.js
│ │ ├── Article.js
│ │ ├── Category.js
│ │ ├── Comment.js
│ │ └── ...
│ ├── routes/ # API rotaları
│ │ ├── auth.js
│ │ ├── articles.js
│ │ ├── users.js
│ │ ├── admin.js
│ │ └── ...
│ ├── middlewares/ # Middleware'ler
│ ├── public/images/ # Yüklenen görseller
│ ├── server.js # Ana server dosyası
│ └── package.json # Node.js bağımlılıkları
```

## 🚀 Kurulum & Çalıştırma

### Gereksinimler
- Flutter SDK 3.7+
- Node.js 16+
- MongoDB
- Git

### 1️⃣ Projeyi Klonlayın
```bash
git clone <repository-url>
cd MediumCloneApp
```

### 2️⃣ Backend Kurulumu
```bash
cd backend
npm install
npm start
```

### 3️⃣ Frontend Kurulumu
```bash
cd frontend
flutter pub get
flutter run
```

### 4️⃣ MongoDB Bağlantısı
Backend klasöründe `.env` dosyası oluşturun:
```env
MONGODB_URI=mongodb://localhost:27017/mediumclone
JWT_SECRET=your_jwt_secret_key
EMAIL_USER=your_email@gmail.com
EMAIL_PASS=your_email_password
```

## 📱 Platform Desteği
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Web

## 🔗 API Endpoints

### Authentication
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| `POST` | `/auth/register` | Kullanıcı kaydı |
| `POST` | `/auth/login` | Kullanıcı girişi |
| `POST` | `/auth/forgot-password` | Şifre sıfırlama |
| `POST` | `/auth/reset-password` | Yeni şifre belirleme |

### Articles
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| `GET` | `/articles` | Tüm makaleler |
| `GET` | `/articles/:id` | Belirli makale |
| `POST` | `/articles` | Yeni makale oluştur |
| `PUT` | `/articles/:id` | Makale güncelle |
| `DELETE` | `/articles/:id` | Makale sil |

### Admin
| Method | Endpoint | Açıklama |
|--------|----------|----------|
| `GET` | `/admin/users` | Kullanıcı listesi |
| `GET` | `/admin/statistics` | Genel istatistikler |
| `POST` | `/admin/themes` | Yeni tema oluştur |
| `PUT` | `/admin/themes/:id` | Tema güncelle |

## 🎨 Tema Sistemi

Uygulama 8 farklı tema seçeneği sunar:
- **Light Theme**: Klasik açık tema
- **Dark Theme**: Modern koyu tema
- **Retro Theme**: Nostaljik renkler
- **Arctic Blue**: Soğuk mavi tonları
- **Coral Sand**: Sıcak mercan renkleri
- **Soft Nature**: Doğal yeşil tonları
- **Auth Theme**: Giriş sayfasına özel tema
- **Admin Theme**: Yönetici paneli teması

## 📸 Ekran Görüntüleri

### Ana Sayfa
- Öne çıkan makaleler
- Kategori filtreleme
- Arama özelliği

### Makale Editörü
- Rich text formatting
- Görsel ekleme
- Kategori seçimi

### Admin Paneli
- İstatistik dashboard'u
- Kullanıcı yönetimi
- Tema editörü

## 🤝 Katkıda Bulunma

1. Bu repoyu fork edin 🍴
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişiklikleri commit edin (`git commit -m 'Add some amazing feature'`)
4. Branch'i push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın 🚀

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

## 👥 Geliştirici

[Geliştirici Adı] - [email@example.com]

## 🙏 Teşekkürler

- Flutter Team
- MongoDB Team
- Tüm açık kaynak katkıda bulunanlar

---

<p align="center">⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın!</p>
