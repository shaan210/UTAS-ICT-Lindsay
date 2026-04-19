package com.salesinterior.app.ui

import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R
import com.salesinterior.app.adapters.HouseAdapter
import com.salesinterior.app.data.House

class HouseListActivity : AppCompatActivity() {

    private companion object {
        const val TAG = "HouseListActivity"
    }

    private lateinit var rvHouses: RecyclerView
    private lateinit var tvNoHouses: TextView
    private lateinit var fabAddHouse: FloatingActionButton
    private lateinit var houseAdapter: HouseAdapter
    private val db = FirebaseFirestore.getInstance()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_house_list)

        setupViews()
        setupRecyclerView()
        observeHouses()
    }

    private fun setupViews() {
        rvHouses = findViewById(R.id.rvHouses)
        tvNoHouses = findViewById(R.id.tvNoHouses)
        fabAddHouse = findViewById(R.id.fabAddHouse)

        fabAddHouse.setOnClickListener {
            Toast.makeText(this, "Add New House Clicked", Toast.LENGTH_SHORT).show()
            // Next step: Navigate to AddHouseActivity
        }
    }

    private fun setupRecyclerView() {
        houseAdapter = HouseAdapter(emptyList())
        rvHouses.layoutManager = LinearLayoutManager(this)
        rvHouses.adapter = houseAdapter
    }

    private fun observeHouses() {
        db.collection("houses")
            .addSnapshotListener { snapshots, e ->
                if (e != null) {
                    Log.w(TAG, "Listen failed.", e)
                    return@addSnapshotListener
                }

                if (snapshots != null) {
                    val houseList = snapshots.toObjects(House::class.java)
                    
                    if (houseList.isEmpty()) {
                        tvNoHouses.visibility = View.VISIBLE
                        rvHouses.visibility = View.GONE
                    } else {
                        tvNoHouses.visibility = View.GONE
                        rvHouses.visibility = View.VISIBLE
                        houseAdapter.updateData(houseList)
                    }
                }
            }
    }
}
