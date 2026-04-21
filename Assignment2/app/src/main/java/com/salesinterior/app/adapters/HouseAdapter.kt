package com.salesinterior.app.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.salesinterior.app.R
import com.salesinterior.app.data.House

class HouseAdapter(
    private var houses: List<House>,
    private val onItemClick: (House) -> Unit
) : RecyclerView.Adapter<HouseAdapter.HouseViewHolder>() {

    class HouseViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val tvHouseName: TextView = view.findViewById(R.id.tvHouseName)
        val tvProjectCode: TextView = view.findViewById(R.id.tvProjectCode)
        val tvAddress: TextView = view.findViewById(R.id.tvAddress)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): HouseViewHolder {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_house, parent, false)
        return HouseViewHolder(view)
    }

    override fun onBindViewHolder(holder: HouseViewHolder, position: Int) {
        val house = houses[position]
        holder.tvHouseName.text = house.clientName
        holder.tvProjectCode.text = "Code: ${house.projectCode}"
        holder.tvAddress.text = "${house.street}, ${house.city} ${house.postcode}"
        
        holder.itemView.setOnClickListener {
            onItemClick(house)
        }
    }

    override fun getItemCount() = houses.size

    fun updateData(newHouses: List<House>) {
        houses = newHouses
        notifyDataSetChanged()
    }
}
