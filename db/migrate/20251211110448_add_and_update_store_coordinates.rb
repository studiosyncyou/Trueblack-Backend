class AddAndUpdateStoreCoordinates < ActiveRecord::Migration[8.0]
  def up
    # Add columns if they don't exist
    unless column_exists?(:stores, :latitude)
      add_column :stores, :latitude, :decimal, precision: 10, scale: 8
    end

    unless column_exists?(:stores, :longitude)
      add_column :stores, :longitude, :decimal, precision: 11, scale: 8
    end

    # Update store coordinates with accurate Google Maps data
    Store.find_by(name: 'Kompally')&.update(
      latitude: 17.5366834,
      longitude: 78.4902905
    )

    Store.find_by(name: 'Loft')&.update(
      latitude: 17.4323211,
      longitude: 78.3825729
    )

    Store.find_by(name: 'Film Nagar')&.update(
      latitude: 17.4141907,
      longitude: 78.407981
    )

    Store.find_by(name: 'Jubilee Hills')&.update(
      latitude: 17.4277035,
      longitude: 78.4051957
    )

    Store.find_by(name: 'Kokapet')&.update(
      latitude: 17.38648,
      longitude: 78.3373395
    )
  end

  def down
    # Only remove columns, don't touch data
    remove_column :stores, :longitude if column_exists?(:stores, :longitude)
    remove_column :stores, :latitude if column_exists?(:stores, :latitude)
  end
end
