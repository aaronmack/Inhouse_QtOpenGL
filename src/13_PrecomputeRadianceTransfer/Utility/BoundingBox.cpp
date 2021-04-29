#include "BoundingBox.h"

BBox::BBox(Triangle &in) {
    _v.resize(2);

    _v[0].setX(Trimin(in._v0.x(), in._v1.x(), in._v2.x()));
    _v[0].setY(Trimin(in._v0.y(), in._v1.y(), in._v2.y()));
    _v[0].setZ(Trimin(in._v0.z(), in._v1.z(), in._v2.z()));

    _v[1].setX(Trimax(in._v0.x(), in._v1.x(), in._v2.x()));
    _v[1].setY(Trimax(in._v0.y(), in._v1.y(), in._v2.y()));
    _v[1].setZ(Trimax(in._v0.z(), in._v1.z(), in._v2.z()));

    setCenter();
}

BBox::BBox(QVector3D pMin, QVector3D pMax) {
    // two point construct a bounding box
    _v.resize(2);

    _v[0] = pMin;
    _v[1] = pMax;

    setCenter();
}

BBox::BBox(QVector<Triangle> &inlist) {
    // get the model bounding box
    if (inlist.count() == 0)
        qErrnoWarning("Triangles list is empty !");

    _v.resize(2);
    // initialize two point
    _v[0] = inlist[0]._v0;
    _v[1] = inlist[1]._v0;

    for(int i = 0; i < inlist.count(); i++) {
        BBox b_temp(inlist[i]);
        for(int j = 0; j < 3; j++) {
            if (b_temp._v[0][j] < _v[0][j]) {
                _v[0][j] = b_temp._v[0][j];
            }
            if (b_temp._v[1][j] > _v[1][j]) {
                _v[1][j] = b_temp._v[1][j];
            }
        }
    }

    setCenter();
}

bool BBox::rayIntersect(Ray &r) {
    float tmin, tmax, tymin, tymax, tzmin, tzmax;

    if (r._dir.x() >= 0)
    {
        tmin = (_v[0].x() - r._o.x()) * r._inv.x();
        tmax = (_v[1].x() - r._o.x()) * r._inv.x();
    }
    else
    {
        tmin = (_v[1].x() - r._o.x()) * r._inv.x();
        tmax = (_v[0].x() - r._o.x()) * r._inv.x();
    }
    if (r._dir.y() >= 0)
    {
        tymin = (_v[0].y() - r._o.y()) * r._inv.y();
        tymax = (_v[1].y() - r._o.y()) * r._inv.y();
    }
    else
    {
        tymin = (_v[1].y() - r._o.y()) * r._inv.y();
        tymax = (_v[0].y() - r._o.y()) * r._inv.y();
    }
    if ((tmin > tymax) || (tymin > tmax))
    {
        return false;
    }
    if (tymin > tmin)
    {
        tmin = tymin;
    }
    if (tymax < tmax)
    {
        tmax = tymax;
    }
    if (r._dir.z() >= 0)
    {
        tzmin = (_v[0].z() - r._o.z()) * r._inv.z();
        tzmax = (_v[1].z() - r._o.z()) * r._inv.z();
    }
    else
    {
        tzmin = (_v[1].z() - r._o.z()) * r._inv.z();
        tzmax = (_v[0].z() - r._o.z()) * r._inv.z();
    }
    if ((tmin > tzmax) || (tzmin > tmax))
    {
        return false;
    }
    if (tzmin > tmin)
    {
        tmin = tzmin;
    }
    if (tzmax < tmax)
    {
        tmax = tzmax;
    }

    return (tmin < r._tmax) && (tmax > r._tmin);
}
