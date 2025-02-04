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

    it { polygon.size.should eq(5) }
    it { (polygon.first == polygon.last).should be_truthy }

    it "should not allow to change coods after initialize" do
      polygon.coords << Geo::Coord.new(0.0, 0.0)
      polygon.size.should eq(5)
    end

    describe "lexicographical order" do
      pos_sw = Geo::Coord.new(-1.0, -1.0)
      pos_se = Geo::Coord.new(1.0, -1.0)
      pos_ne = Geo::Coord.new(1.0, 1.0)
      pos_nw = Geo::Coord.new(-1.0, 1.0)

      lexicographical_order = [pos_sw, pos_se, pos_ne, pos_nw, pos_sw]

      it do
        polygon = Geo::Polygon.new([pos_sw, pos_se, pos_ne, pos_nw])
        polygon.coords.should eq(lexicographical_order)
      end

      it do
        polygon = Geo::Polygon.new([pos_se, pos_ne, pos_nw, pos_sw])
        polygon.coords.should eq(lexicographical_order)
      end

      it do
        polygon = Geo::Polygon.new([pos_se, pos_ne, pos_nw, pos_sw, pos_se])
        polygon.coords.should eq(lexicographical_order)
      end

      it "clockwise" do
        clockwise_polygon = Geo::Polygon.new([pos_nw, pos_ne, pos_se, pos_sw])
        clockwise_polygon.coords.should eq(lexicographical_order)
      end
    end

    context "convex hull" do
      points = [
        {1.0, 1.0}, {1.0, 0.0}, {1.0, -1.0}, {0.0, -1.0}, {-1.0, -1.0}, {-1.0, 0.0}, {-1.0, 1.0}, {0.0, 1.0}, {0.0, 0.0},
      ].map { |point| Geo::Coord.new(point[0], point[1]) }

      expected = [
        {-1.0, -1.0}, {1.0, -1.0}, {1.0, 1.0}, {-1.0, 1.0}, {-1.0, -1.0},
      ].map { |point| Geo::Coord.new(point[0], point[1]) }

      polygon = Geo::Polygon.new(points, convex_hull: true)

      it { polygon.coords.should eq(expected) }
    end
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

  describe "#area" do
    coords = [
      Geo::Coord.new(-15, 125),
      Geo::Coord.new(-22, 113),
      Geo::Coord.new(-37, 117),
      Geo::Coord.new(-33, 130),
      Geo::Coord.new(-39, 148),
      Geo::Coord.new(-27, 154),
      Geo::Coord.new(-15, 144),
      Geo::Coord.new(-15, 125),
    ]

    polygon = Geo::Polygon.new(coords)

    it { polygon.area.should be_a(RingArea::Area) }
    it { polygon.area.to_meters.should eq(7748891609977.457) }
  end

  describe "#to_geojson" do
    coords = [
      Geo::Coord.new(-15, 125),
      Geo::Coord.new(-22, 113),
      Geo::Coord.new(-37, 117),
      Geo::Coord.new(-33, 130),
      Geo::Coord.new(-39, 148),
      Geo::Coord.new(-27, 154),
      Geo::Coord.new(-15, 144),
      Geo::Coord.new(-15, 125),
    ]

    polygon = Geo::Polygon.new(coords)
    geojson = polygon.to_geojson

    geojson.should be_a(GeoJSON::Polygon)
  end

  describe "#to_wkt" do
    it "outputs a Well Known Text format" do
      polygon = Geo::Polygon.new([
        Geo::Coord.new(10, 30),
        Geo::Coord.new(20, 10),
        Geo::Coord.new(40, 20),
        Geo::Coord.new(40, 40),
      ])

      polygon.to_wkt.should eq "POLYGON((30 10, 10 20, 20 40, 40 40, 30 10))"
    end
  end

  describe "comparisons" do
    describe "equality" do
      polygon1 = Geo::Polygon.new([pos1, pos2])
      polygon2 = Geo::Polygon.new([pos1, pos2])
      polygon3 = Geo::Polygon.new([pos1, pos2, pos3])
      polygon4 = Geo::Polygon.new([pos2, pos1])
      polygon5 = Geo::Polygon.new([pos1, pos2, pos1])

      it { (polygon1 == polygon1).should be_truthy }
      it { (polygon1 == polygon2).should be_truthy }
      it { (polygon1 == polygon3).should be_falsey }
      it { (polygon1 == polygon4).should be_truthy }
      it { (polygon1 == polygon5).should be_truthy }
    end
  end
end
