const express = require("express");
const router = express.Router();
const Report = require("../models/Report");

router.post("/", async (req, res) => {
  try {
    const { articleId, reason, description } = req.body;

    if (!articleId || !reason) {
      return res.status(400).json({ message: "Eksik bilgi gönderildi." });
    }

    const newReport = new Report({
      article: articleId,
      reason,
      description
    });
    console.log(articleId,reason)
    await newReport.save();
    res.status(200).json({ message: "Şikayet başarıyla gönderildi." });
  } catch (error) {
    res.status(500).json({ message: "Sunucu hatası", error: error.message });
  }
});

router.get("/all", async (req, res) => {
  try {
    const reports = await Report.find()
      .populate("article")
      .sort({ createdAt: -1 });
    res.status(200).json(reports);
  } catch (error) {
    res.status(500).json({ message: "Şikayetler alınamadı", error: error.message });
  }
});

router.patch("/:id/resolve", async (req, res) => {
  try {
    await Report.findByIdAndUpdate(req.params.id, { resolved: true });
    res.status(200).json({ message: "Şikayet çözüldü olarak işaretlendi." });
  } catch (error) {
    res.status(500).json({ message: "İşaretleme başarısız", error: error.message });
  }
});

router.delete("/:id/delete", async (req, res) => {
  try {
    await Report.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: "Şikayet silindi." });
  } catch (error) {
    res.status(500).json({ message: "Silme başarısız", error: error.message });
  }
});


module.exports = router;
