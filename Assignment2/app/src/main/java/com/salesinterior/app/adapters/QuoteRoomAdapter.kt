package com.salesinterior.app.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.salesinterior.app.R
import java.util.Locale

data class RoomQuote(
    val roomName: String,
    val windowCount: Int,
    val floorCount: Int,
    val totalCost: Double
)

class QuoteRoomAdapter(private val roomQuotes: List<RoomQuote>) :
    RecyclerView.Adapter<QuoteRoomAdapter.QuoteViewHolder>() {

    class QuoteViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvRoomName: TextView = view.findViewById(R.id.tvQuoteRoomName)
        val tvRoomDetails: TextView = view.findViewById(R.id.tvQuoteRoomDetails)
        val tvRoomTotal: TextView = view.findViewById(R.id.tvQuoteRoomTotal)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): QuoteViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_quote_room, parent, false)
        return QuoteViewHolder(view)
    }

    override fun onBindViewHolder(holder: QuoteViewHolder, position: Int) {
        val quote = roomQuotes[position]
        holder.tvRoomName.text = quote.roomName
        holder.tvRoomDetails.text = "${quote.windowCount} Windows, ${quote.floorCount} Floor Spaces"
        holder.tvRoomTotal.text = String.format(Locale.getDefault(), "$%.2f", quote.totalCost)
    }

    override fun getItemCount() = roomQuotes.size
}
