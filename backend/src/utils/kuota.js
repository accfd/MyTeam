async function getPositionCapacity(connection, idTim, posisi) {
  const [needs] = await connection.query(`
    SELECT jumlah_anggota_dibutuhkan
    FROM Kebutuhan_Anggota_Tim
    WHERE id_tim = ?
      AND LOWER(TRIM(posisi_dibutuhkan)) = LOWER(TRIM(?))
    FOR UPDATE
  `, [idTim, posisi]);

  const required = needs.reduce(
    (total, item) => total + Number(item.jumlah_anggota_dibutuhkan),
    0
  );
  const [[members]] = await connection.query(`
    SELECT COUNT(*) AS jumlah
    FROM Anggota_Tim
    WHERE id_tim = ?
      AND LOWER(TRIM(posisi)) = LOWER(TRIM(?))
  `, [idTim, posisi]);
  const filled = Number(members.jumlah);

  return {
    required,
    filled,
    remaining: Math.max(required - filled, 0),
    available: required > filled
  };
}

module.exports = { getPositionCapacity };
