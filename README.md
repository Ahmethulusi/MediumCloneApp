
<h1 align="center">📰 MediumCloneApp</h1>
<p align="center"><i>A clean and powerful Medium.com clone with Flutter, Node.js, and MongoDB</i></p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19-blue.svg" />
  <img src="https://img.shields.io/badge/Node.js-Express-green.svg" />
  <img src="https://img.shields.io/badge/MongoDB-Database-brightgreen.svg" />
  <img src="https://img.shields.io/badge/JWT-Auth-yellow.svg" />
</p>


## 🚀 Proje Hakkında
Bu proje, kullanıcıların makale okuyup paylaşabileceği, kişisel profillerini yönetebileceği bir platform sunar. Uygulama Flutter ile geliştirilmiş olup, arka planda Node.js ve MongoDB kullanmaktadır.

## 📌 Özellikler
- 🔐 Kullanıcı kayıt & giriş (JWT Authentication)
- 🏠 Ana sayfa (Öne çıkan makaleler)
- 📚 Kütüphane (Kaydedilen makaleler)
- ✍️ Makale yazma & düzenleme
- 👤 Kullanıcı profili yönetimi
- 📂 Kategoriler & Etiketler desteği
- ⚡ Gerçek zamanlı veri güncelleme

## 🛠️ Kullanılan Teknolojiler
- **Flutter** (Frontend)
- **Dart** (Frontend dili)
- **Node.js & Express.js** (Backend)
- **MongoDB & Mongoose** (Veritabanı)
- **JWT** (Kimlik doğrulama)

## 📂 Proje Dizini Yapısı
```
medium_clone/
│── lib/
│   ├── components/        # Veri modelleri ve bileşenler
│   ├── screens/           # Uygulama ekranları
│   ├── services/          # API istekleri
│   ├── widgets/           # UI bileşenleri
│   ├── main.dart          # Ana dosya
│
│── assets/
│   ├── images/            # Uygulama için statik görseller
│   ├── articles.json      # Örnek makale verisi
│
│── pubspec.yaml           # Flutter bağımlılıkları
│── README.md              # Proje dokümantasyonu
```

## 📦 Kurulum & Çalıştırma
### 1️⃣ Flutter Bağımlılıklarını Yükleyin
```sh
flutter pub get
```
### 2️⃣ Uygulamayı Çalıştırın
```sh
flutter run
```

## 🎨 Ekran Görüntüleri
📌 **Giriş Ekranı**

📌 **Ana Sayfa**

📌 **Profil Yönetimi**

(Ekran görüntüleri buraya eklenebilir.)

## 🛠️ API Bağlantıları
| Endpoint | Açıklama |
|----------|-------------|
| `POST /auth/login` | Kullanıcı giriş yapar |
| `POST /auth/register` | Yeni kullanıcı kaydı |
| `GET /articles` | Tüm makaleleri getirir |
| `POST /articles` | Yeni makale oluşturur |
| `PUT /articles/:id` | Makale günceller |
| `DELETE /articles/:id` | Makale siler |

## 📌 Katkıda Bulunma
Projeye katkıda bulunmak için:
1. Bu repoyu forklayın 🍴
2. Yeni bir branch oluşturun (`git checkout -b feature-isim`)
3. Değişiklikleri yapın ve commit atın (`git commit -m 'Yeni özellik ekledim'`)
4. Push edin (`git push origin feature-isim`)
5. Pull Request gönderin 🚀
