package com.salesinterior.app.ui

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.adapters.QuoteRoomAdapter
import com.salesinterior.app.adapters.RoomQuote
import com.salesinterior.app.data.Room
import java.util.Locale

class QuoteActivity : AppCompatActivity() {

    private lateinit var tvHouseName: TextView
    private lateinit var rvQuoteRooms: RecyclerView
    private lateinit var tvGrandTotal: TextView
    private lateinit var btnDone: Button

    private val db = FirebaseFirestore.getInstance()
    private var houseId: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_quote)

        houseId = intent.getStringExtra("HOUSE_ID")
        val houseName = intent.getStringExtra("HOUSE_NAME")

        tvHouseName = findViewById(R.id.tvQuoteHouseName)
        tvHouseName.text = houseName
        tvGrandTotal = findViewById(R.id.tvGrandTotalValue)
        btnDone = findViewById(R.id.btnDone)
        rvQuoteRooms = findViewById(R.id.rvQuoteRooms)

        btnDone.setOnClickListener { finish() }

        fetchRoomsAndCalculateQuote()
    }

    private fun fetchRoomsAndCalculateQuote() {
        val hId = houseId ?: return

        db.collection("houses").document(hId).collection("rooms")
            .get()
            .addOnSuccessListener { snapshot ->
                val rooms = snapshot.toObjects(Room::class.java)
                calculateQuote(rooms)
            }
            .addOnFailureListener {
                Toast.makeText(this, "Error fetching data for quote", Toast.LENGTH_SHORT).show()
            }
    }

    private fun calculateQuote(rooms: List<Room>) {
        val roomQuotes = mutableListOf<RoomQuote>()
        var grandTotal = 0.0

        for (room in rooms) {
            var roomTotal = 0.0
            var windowCount = 0
            var floorCount = 0

            for (m in room.measurements) {
                val cost = when (m.type) {
                    "WINDOW" -> {
                        windowCount++
                        val width = m.width ?: 0.0
                        val height = m.height ?: 0.0
                        // Formula: (Width * Height) * Price
                        (width * height) * m.productPrice
                    }
                    "FLOOR_SPACE" -> {
                        floorCount++
                        val area = m.area ?: 0.0
                        // Formula: Area * Price
                        area * m.productPrice
                    }
                    else -> 0.0
                }
                roomTotal += cost
            }

            roomQuotes.add(
                RoomQuote(
                    roomName = room.name,
                    windowCount = windowCount,
                    floorCount = floorCount,
                    totalCost = roomTotal
                )
            )
            grandTotal += roomTotal
        }

        displayQuote(roomQuotes, grandTotal)
    }

    private fun displayQuote(roomQuotes: List<RoomQuote>, grandTotal: Double) {
        rvQuoteRooms.layoutManager = LinearLayoutManager(this)
        rvQuoteRooms.adapter = QuoteRoomAdapter(roomQuotes)
        
        tvGrandTotal.text = String.format(Locale.getDefault(), "$%.2f", grandTotal)
    }
}
