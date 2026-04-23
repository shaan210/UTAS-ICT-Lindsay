package com.salesinterior.app.ui

import android.content.Intent
import android.os.Bundle
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.adapters.RoomAdapter
import com.salesinterior.app.data.Room

class HouseDetailActivity : AppCompatActivity() {

    private lateinit var tvHouseName: TextView
    private lateinit var rvRooms: RecyclerView
    private lateinit var fabAddRoom: FloatingActionButton
    private lateinit var btnViewQuote: android.widget.Button
    private lateinit var roomAdapter: RoomAdapter
    
    private var houseId: String? = null
    private val db = FirebaseFirestore.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_house_detail)

        houseId = intent.getStringExtra("HOUSE_ID")
        val houseName = intent.getStringExtra("HOUSE_NAME")

        tvHouseName = findViewById(R.id.tvHouseNameDetail)
        tvHouseName.text = houseName

        setupRecyclerView()
        setupFab()
        setupQuoteButton()
        listenForRooms()
    }

    private fun setupQuoteButton() {
        btnViewQuote = findViewById(R.id.btnViewQuote)
        btnViewQuote.setOnClickListener {
            val intent = Intent(this, QuoteActivity::class.java)
            intent.putExtra("HOUSE_ID", houseId)
            intent.putExtra("HOUSE_NAME", tvHouseName.text.toString())
            startActivity(intent)
        }
    }

    private fun setupRecyclerView() {
        rvRooms = findViewById(R.id.rvRooms)
        roomAdapter = RoomAdapter(emptyList()) { room ->
            val intent = Intent(this, RoomDetailActivity::class.java)
            intent.putExtra("HOUSE_ID", houseId)
            intent.putExtra("ROOM_ID", room.id)
            intent.putExtra("ROOM_NAME", room.name)
            startActivity(intent)
        }
        rvRooms.layoutManager = LinearLayoutManager(this)
        rvRooms.adapter = roomAdapter
    }

    private fun setupFab() {
        fabAddRoom = findViewById(R.id.fabAddRoom)
        fabAddRoom.setOnClickListener {
            showAddRoomDialog()
        }
    }

    private fun showAddRoomDialog() {
        val editText = EditText(this)
        editText.hint = "e.g. Living Room, Bedroom 1"
        
        AlertDialog.Builder(this)
            .setTitle("Add New Room")
            .setView(editText)
            .setPositiveButton("Add") { _, _ ->
                val roomName = editText.text.toString().trim()
                if (roomName.isNotEmpty()) {
                    saveRoomToFirestore(roomName)
                } else {
                    Toast.makeText(this, "Room name cannot be empty", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun saveRoomToFirestore(name: String) {
        val hId = houseId ?: return
        val roomRef = db.collection("houses").document(hId).collection("rooms").document()
        val room = Room(id = roomRef.id, name = name)
        
        roomRef.set(room)
            .addOnSuccessListener {
                Toast.makeText(this, "Room added", Toast.LENGTH_SHORT).show()
            }
            .addOnFailureListener {
                Toast.makeText(this, "Error adding room", Toast.LENGTH_SHORT).show()
            }
    }

    private fun listenForRooms() {
        val hId = houseId ?: return
        db.collection("houses").document(hId).collection("rooms")
            .addSnapshotListener { snapshot, e ->
                if (e != null) return@addSnapshotListener
                
                val rooms = snapshot?.toObjects(Room::class.java) ?: emptyList()
                roomAdapter.updateRooms(rooms)
            }
    }
}
