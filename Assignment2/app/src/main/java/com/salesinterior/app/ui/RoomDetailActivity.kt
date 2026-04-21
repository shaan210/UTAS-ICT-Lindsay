package com.salesinterior.app.ui

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.textfield.TextInputEditText
import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.data.Measurement
import com.salesinterior.app.data.Room

class RoomDetailActivity : AppCompatActivity() {

    private lateinit var tvRoomName: TextView
    private lateinit var etWindowWidth: TextInputEditText
    private lateinit var etWindowHeight: TextInputEditText
    private lateinit var etFloorArea: TextInputEditText
    private lateinit var btnAddWindow: Button
    private lateinit var btnAddFloor: Button
    private lateinit var tvSummaryText: TextView

    private var houseId: String? = null
    private var roomId: String? = null
    private val db = FirebaseFirestore.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_room_detail)

        houseId = intent.getStringExtra("HOUSE_ID")
        roomId = intent.getStringExtra("ROOM_ID")
        val roomName = intent.getStringExtra("ROOM_NAME")

        setupViews(roomName)
        listenForRoomUpdates()
    }

    private fun setupViews(roomName: String?) {
        tvRoomName = findViewById(R.id.tvRoomNameDisplay)
        tvRoomName.text = roomName

        etWindowWidth = findViewById(R.id.etWindowWidth)
        etWindowHeight = findViewById(R.id.etWindowHeight)
        etFloorArea = findViewById(R.id.etFloorArea)
        btnAddWindow = findViewById(R.id.btnAddWindow)
        btnAddFloor = findViewById(R.id.btnAddFloor)
        tvSummaryText = findViewById(R.id.tvSummaryText)

        btnAddWindow.setOnClickListener { validateAndAddWindow() }
        btnAddFloor.setOnClickListener { validateAndAddFloor() }
    }

    private fun validateAndAddWindow() {
        val widthStr = etWindowWidth.text.toString()
        val heightStr = etWindowHeight.text.toString()

        val width = widthStr.toDoubleOrNull()
        val height = heightStr.toDoubleOrNull()

        if (width == null || width <= 0) {
            etWindowWidth.error = "Valid number > 0 required"
            return
        }
        if (height == null || height <= 0) {
            etWindowHeight.error = "Valid number > 0 required"
            return
        }

        val measurement = Measurement(
            type = "WINDOW",
            width = width,
            height = height
        )
        saveMeasurement(measurement)
        etWindowWidth.text = null
        etWindowHeight.text = null
    }

    private fun validateAndAddFloor() {
        val areaStr = etFloorArea.text.toString()
        val area = areaStr.toDoubleOrNull()

        if (area == null || area <= 0) {
            etFloorArea.error = "Valid number > 0 required"
            return
        }

        val measurement = Measurement(
            type = "FLOOR_SPACE",
            area = area
        )
        saveMeasurement(measurement)
        etFloorArea.text = null
    }

    private fun saveMeasurement(measurement: Measurement) {
        val hId = houseId ?: return
        val rId = roomId ?: return

        db.collection("houses").document(hId)
            .collection("rooms").document(rId)
            .update("measurements", FieldValue.arrayUnion(measurement))
            .addOnSuccessListener {
                Toast.makeText(this, "Measurement added", Toast.LENGTH_SHORT).show()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Error saving measurement", Toast.LENGTH_SHORT).show()
            }
    }

    private fun listenForRoomUpdates() {
        val hId = houseId ?: return
        val rId = roomId ?: return

        db.collection("houses").document(hId)
            .collection("rooms").document(rId)
            .addSnapshotListener { snapshot, e ->
                if (e != null) return@addSnapshotListener
                val room = snapshot?.toObject(Room::class.java)
                val measurements = room?.measurements ?: emptyList()
                
                val windows = measurements.count { it.type == "WINDOW" }
                val floors = measurements.count { it.type == "FLOOR_SPACE" }
                tvSummaryText.text = "$windows Windows, $floors Floor Spaces"
            }
    }
}
