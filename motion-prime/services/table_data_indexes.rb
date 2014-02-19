class TableDataIndexes
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def max_index(*indexes)
    [*indexes].compact.max &method(:compare_indexes)
  end

  def compare_indexes(a, b)
    return 0 if a == b
    a.section > b.section || a.row > b.row ? 1 : -1
  end

  def greater_than(a, b)
    compare_indexes(a, b) > 0
  end

  def less_than(a, b)
    compare_indexes(a, b) < 0
  end

  def sum_index(a, rows, crop_to_edges = true)
    row = a.row + rows
    section = a.section

    max_row = count_in_section(a.section) - 1
    if row < 0 || row > max_row
      direction = row < 0 ? -1 : 1

      section = a.section + direction
      edge_row = [[0, row].max, max_row].min

      max_section = sections_count - 1
      if section < 0 || section > max_section
        edge_section = [[section, 0].max, max_section].min
        return crop_to_edges ? NSIndexPath.indexPathForRow(edge_row, inSection: edge_section) : false
      end

      start_row = edge_row.zero? ? count_in_section(section) - 1 : 0
      rows_left = rows - (edge_row - a.row) - direction
      sum_index(NSIndexPath.indexPathForRow(start_row, inSection: section), rows_left)
    else
      NSIndexPath.indexPathForRow(row, inSection: section)
    end
  end

  def count_in_section(id)
    flat_data? ? data.count : data[id].count
  end

  def sections_count
    flat_data? ? 1 : data.count
  end

  def flat_data?
    !data.first.is_a?(Array)
  end
end