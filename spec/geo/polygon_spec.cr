require "../spec_helper"

describe Geo::Polygon do
  # A simple square-ish polygon for easy testing
  pos1 = Geo::Coord.new(45.3142533036254, -93.47527313511819)
  pos2 = Geo::Coord.new(45.31232182518015, -93.34893036168069)
  pos3 = Geo::Coord.new(45.23694281999268, -93.35167694371194)
  pos4 = Geo::Coord.new(45.23500870841669, -93.47801971714944)
  pos5 = Geo::Coord.new(45.3142533036254, -93.47527313511819)

  describe "#initialize" do
    coords = [pos1, pos2, pos3, pos4]
    polygon = Geo::Polygon.new(coords)

    it { polygon.last.should eq(pos1) }
    it { polygon.size.should eq(5) }
    it { polygon[2].should eq(pos3) }
  end

  describe "#contains?" do
    coords = [pos1, pos2, pos3, pos4, pos5]
    polygon = Geo::Polygon.new(coords)

    coord_inside = Geo::Coord.new(45.27428243796789, -93.41648483416066)
    coord_outside = Geo::Coord.new(45.45411010558687, -93.78151703160256)

    it { polygon.contains?(coord_inside).should be_truthy }
    it { polygon.contains?(coord_outside).should be_falsey }
  end

  describe "#centroid" do
    coords = [pos1, pos2, pos3, pos4, pos5]
    polygon = Geo::Polygon.new(coords)
    center_coord = Geo::Coord.new(45.27463866133501, -93.41400121829719)

    it { polygon.centroid.should eq(center_coord) }
  end

  describe "equality comparisons" do
    polygon1 = Geo::Polygon.new([pos1, pos2])
    polygon2 = Geo::Polygon.new([pos1, pos2])
    polygon3 = Geo::Polygon.new([pos1, pos2, pos3])

    it { (polygon1 == polygon1).should be_truthy }
    it { (polygon1 == polygon2).should be_truthy }
    it { (polygon1 == polygon3).should be_falsey }
  end
end
