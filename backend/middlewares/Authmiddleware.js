// const jwt = require('jsonwebtoken');

// // Yetki kontrolü yapan middleware
// const authMiddleware = (roles) => {
//   return (req, res, next) => {
//     const userRole = req.user.role; // Kullanıcının rolü

//     if (!roles.includes(userRole)) {
//       return res.status(403).json({ error: "Bu işlemi yapmak için yetkiniz yok!" });
//     }

//     next(); // Eğer yetkisi varsa işlemi devam ettir
//   };
// };

// module.exports = authMiddleware;


const jwt = require('jsonwebtoken');

// Yetki kontrolü yapan middleware
const authMiddleware = (allowedRoles) => {
  return (req, res, next) => {
    try {
      // Authorization header'ı kontrol et
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: "Yetkisiz erişim! Lütfen giriş yapın." });
      }

      // Token'ı al ve doğrula
      const token = authHeader.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY);

      // req.user oluştur ve kullanıcı bilgilerini ekle
      req.user = decoded;

      // Kullanıcının rolünü kontrol etmeden önce undefined olup olmadığını kontrol et
      if (!req.user || !req.user.role) {
        return res.status(403).json({ error: "Yetki hatası: Kullanıcı rolü bulunamadı!" });
      }

      // Kullanıcının rolünü kontrol et
      if (!allowedRoles.includes(req.user.role)) {
        return res.status(403).json({ error: "Bu işlemi yapmak için yetkiniz yok!" });
      }

      next(); // Yetkili kullanıcı devam edebilir
    } catch (error) {
      return res.status(401).json({ error: "Geçersiz veya süresi dolmuş token! Lütfen tekrar giriş yapın." });
    }
  };
};

module.exports = authMiddleware;
