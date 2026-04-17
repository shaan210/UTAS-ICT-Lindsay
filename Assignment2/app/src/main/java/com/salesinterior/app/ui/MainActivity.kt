package com.salesinterior.app.ui

import android.os.Bundle
import android.util.Log
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.google.firebase.firestore.FirebaseFirestore
import com.salesinterior.app.R

class MainActivity : AppCompatActivity() {

    private companion object {
        const val TAG = "MainActivity"
    }

    private lateinit var tvStatus: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        tvStatus = findViewById(R.id.tvStatus)

        testFirestoreConnection()
    }

    private fun testFirestoreConnection() {
        val db = FirebaseFirestore.getInstance()
        
        // Simple write/read test to verify connection
        val testData = hashMapOf("status" to "connected")
        
        db.collection("connection_test")
            .document("test")
            .set(testData)
            .addOnSuccessListener {
                Log.d(TAG, "Firestore successfully connected!")
                tvStatus.text = "Firebase Status: Connected"
            }
            .addOnFailureListener { e ->
                Log.w(TAG, "Error connecting to Firestore", e)
                tvStatus.text = "Firebase Status: Connection Failed"
            }
    }
}
